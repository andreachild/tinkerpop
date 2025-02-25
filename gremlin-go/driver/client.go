/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
*/

package gremlingo

import (
	"crypto/tls"
	"runtime"
	"time"

	"golang.org/x/text/language"
)

// ClientSettings is used to modify a Client's settings on initialization.
type ClientSettings struct {
	TraversalSource   string
	LogVerbosity      LogVerbosity
	Logger            Logger
	Language          language.Tag
	AuthInfo          AuthInfoProvider
	TlsConfig         *tls.Config
	KeepAliveInterval time.Duration
	WriteDeadline     time.Duration
	ConnectionTimeout time.Duration
	EnableCompression bool
	ReadBufferSize    int
	WriteBufferSize   int

	// Maximum number of concurrent connections. Default: number of runtime processors
	MaximumConcurrentConnections int
	EnableUserAgentOnConnect     bool
}

// Client is used to connect and interact with a Gremlin-supported server.
type Client struct {
	url                string
	traversalSource    string
	logHandler         *logHandler
	session            string
	connectionSettings *connectionSettings
	httpProtocol       *httpProtocol
}

// NewClient creates a Client and configures it with the given parameters.
// Important note: to avoid leaking a connection, always close the Client.
func NewClient(url string, configurations ...func(settings *ClientSettings)) (*Client, error) {
	settings := &ClientSettings{
		TraversalSource:          "g",
		LogVerbosity:             Info,
		Logger:                   &defaultLogger{},
		Language:                 language.English,
		AuthInfo:                 &AuthInfo{},
		TlsConfig:                &tls.Config{},
		KeepAliveInterval:        keepAliveIntervalDefault,
		WriteDeadline:            writeDeadlineDefault,
		ConnectionTimeout:        connectionTimeoutDefault,
		EnableCompression:        false,
		EnableUserAgentOnConnect: true,
		// ReadBufferSize and WriteBufferSize specify I/O buffer sizes in bytes. If a buffer
		// size is zero, then a useful default size is used. The I/O buffer sizes
		// do not limit the size of the messages that can be sent or received.
		ReadBufferSize:  0,
		WriteBufferSize: 0,

		MaximumConcurrentConnections: runtime.NumCPU(),
	}
	for _, configuration := range configurations {
		configuration(settings)
	}

	connSettings := &connectionSettings{
		authInfo:                 settings.AuthInfo,
		tlsConfig:                settings.TlsConfig,
		keepAliveInterval:        settings.KeepAliveInterval,
		writeDeadline:            settings.WriteDeadline,
		connectionTimeout:        settings.ConnectionTimeout,
		enableCompression:        settings.EnableCompression,
		readBufferSize:           settings.ReadBufferSize,
		writeBufferSize:          settings.WriteBufferSize,
		enableUserAgentOnConnect: settings.EnableUserAgentOnConnect,
	}

	logHandler := newLogHandler(settings.Logger, settings.LogVerbosity, settings.Language)

	httpProt, err := newHttpProtocol(logHandler, url, connSettings)
	if err != nil {
		return nil, err
	}

	client := &Client{
		url:                url,
		traversalSource:    settings.TraversalSource,
		logHandler:         logHandler,
		session:            "",
		connectionSettings: connSettings,
		httpProtocol:       httpProt,
	}

	return client, nil
}

// Close closes the client via connection.
// This is idempotent due to the underlying close() methods being idempotent as well.
func (client *Client) Close() {
	// If it is a session, call closeSession
	if client.session != "" {
		// TODO remove references to session
		client.session = ""
	}
	client.logHandler.logf(Info, closeClient, client.url)
}

func (client *Client) errorCallback() {
	client.logHandler.log(Error, errorCallback)
}

// SubmitWithOptions submits a Gremlin script to the server with specified RequestOptions and returns a ResultSet.
func (client *Client) SubmitWithOptions(traversalString string, requestOptions RequestOptions) (ResultSet, error) {
	client.logHandler.logf(Debug, submitStartedString, traversalString)
	request := makeStringRequest(traversalString, client.traversalSource, client.session, requestOptions)

	rs, err := client.httpProtocol.send(&request)
	return rs, err
}

// Submit submits a Gremlin script to the server and returns a ResultSet. Submit can optionally accept a map of bindings
// to be applied to the traversalString, it is preferred however to instead wrap any bindings into a RequestOptions
// struct and use SubmitWithOptions().
func (client *Client) Submit(traversalString string, bindings ...map[string]interface{}) (ResultSet, error) {
	requestOptionsBuilder := new(RequestOptionsBuilder)
	if len(bindings) > 0 {
		requestOptionsBuilder.SetBindings(bindings[0])
	}
	return client.SubmitWithOptions(traversalString, requestOptionsBuilder.Create())
}

// submitGremlinLang submits GremlinLang to the server to execute and returns a ResultSet.
// TODO test and update when connection is set up
func (client *Client) submitGremlinLang(gremlinLang *GremlinLang) (ResultSet, error) {
	client.logHandler.logf(Debug, submitStartedString, *gremlinLang)
	// TODO placeholder
	requestOptionsBuilder := new(RequestOptionsBuilder)
	request := makeStringRequest(gremlinLang.GetGremlin(), client.traversalSource, client.session, requestOptionsBuilder.Create())
	return client.httpProtocol.send(&request)
}

// submitBytecode submits Bytecode to the server to execute and returns a ResultSet.
func (client *Client) submitBytecode(bytecode *Bytecode) (ResultSet, error) {
	client.logHandler.logf(Debug, submitStartedBytecode, *bytecode)
	request := makeBytecodeRequest(bytecode, client.traversalSource, client.session)
	return client.httpProtocol.send(&request)
}

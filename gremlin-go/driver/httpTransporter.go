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
	"bytes"
	"compress/zlib"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"sync"
)

// TODO decide channel size when chunked response handling is implemented - for now just set to 1
const responseChannelSizeDefault = 1

// HttpTransporter responsible for sending and receiving bytes to/from the server
type HttpTransporter struct {
	url             string
	isClosed        bool
	connSettings    *connectionSettings
	responseChannel chan []byte // receives response bytes from the server
	httpClient      *http.Client
	wg              *sync.WaitGroup
	logHandler      *logHandler
}

func NewHttpTransporter(url string, connSettings *connectionSettings, httpClient *http.Client, logHandler *logHandler) *HttpTransporter {
	wg := &sync.WaitGroup{}

	return &HttpTransporter{
		url:             url,
		connSettings:    connSettings,
		responseChannel: make(chan []byte, responseChannelSizeDefault),
		httpClient:      httpClient,
		wg:              wg,
		logHandler:      logHandler,
	}
}

// Write sends bytes to the server as a POST request and sends received response bytes to the responseChannel
func (transporter *HttpTransporter) Write(data []byte) error {
	req, err := http.NewRequest("POST", transporter.url, bytes.NewBuffer(data))
	if err != nil {
		transporter.logHandler.logf(Error, failedToSendRequest, err.Error())
		return err
	}
	req.Header.Set("content-type", graphBinaryMimeType)
	req.Header.Set("accept", graphBinaryMimeType)
	if transporter.connSettings.enableUserAgentOnConnect {
		req.Header.Set(userAgentHeader, userAgent)
	}
	if transporter.connSettings.enableCompression {
		req.Header.Set("accept-encoding", "deflate")
	}

	fmt.Println("Sending request")
	resp, err := transporter.httpClient.Do(req)
	if err != nil {
		transporter.logHandler.logf(Error, failedToSendRequest, err.Error())
		return err
	}

	reader := resp.Body
	if resp.Header.Get("content-encoding") == "deflate" {
		reader, err = zlib.NewReader(resp.Body)
		if err != nil {
			transporter.logHandler.logf(Error, failedToReceiveResponse, err.Error())
			return err
		}
	}

	// TODO handle chunked encoding and send chunks to responseChannel
	all, err := io.ReadAll(reader)
	if err != nil {
		transporter.logHandler.logf(Error, failedToReceiveResponse, err.Error())
		return err
	}
	err = reader.Close()
	if err != nil {
		return err
	}

	str := hex.EncodeToString(all)
	_, _ = fmt.Fprintf(os.Stdout, "Received response data : %s\n", str)

	fmt.Println("Sending response to responseChannel")
	transporter.responseChannel <- all
	return nil
}

// Read reads bytes from the responseChannel
func (transporter *HttpTransporter) Read() ([]byte, error) {
	fmt.Println("Reading from responseChannel")
	msg, ok := <-transporter.responseChannel
	if !ok {
		return []byte{}, errors.New("failed to read from response channel")
	}
	return msg, nil
}

// Close closes the transporter and its corresponding responseChannel
func (transporter *HttpTransporter) Close() {
	fmt.Println("Closing http transporter")
	if !transporter.isClosed {
		if transporter.responseChannel != nil {
			close(transporter.responseChannel)
		}
		transporter.isClosed = true
	}
}

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
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
)

type httpTransporter struct {
	url             string
	isClosed        bool
	connSettings    *connectionSettings
	responseChannel chan []byte
}

func (transporter *httpTransporter) Connect() (err error) {
	// http transporter delegates connection management to the http client
	// TODO verify that connections are being reused and cleaned up when appropriate
	return
}

func (transporter *httpTransporter) Write(data []byte) error {
	fmt.Println("Sending request message")
	u, _ := url.Parse(transporter.url)
	body := io.NopCloser(bytes.NewReader(data))

	req := http.Request{
		Method: "POST",
		URL:    u,
		Header: map[string][]string{
			"content-type": {"application/vnd.graphbinary-v4.0"},
			"host":         {"localhost"},
			"accept":       {"application/vnd.graphbinary-v4.0"},
			// TODO handle response compression
			//"accept-encoding": {"deflate"},
			// TODO set user agent header
			//"user-agent" : ""
		},
		Body:          body,
		ContentLength: int64(len(data)),
		// TODO handle chunked encoding
		//TransferEncoding: nil,
	}

	transport := &http.Transport{
		TLSClientConfig: transporter.connSettings.tlsConfig,
		MaxConnsPerHost: 0, // TODO
		IdleConnTimeout: 0, // TODO
	}

	// TODO do not create new client for each request
	client := &http.Client{
		Transport: transport,
		Timeout:   transporter.connSettings.connectionTimeout,
	}

	resp, err := client.Do(&req)
	if err != nil {
		return err
	}

	// TODO handle response chunks
	all, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	str := hex.EncodeToString(all)
	_, _ = fmt.Fprintf(os.Stdout, "Received response data : %s\n", str)

	fmt.Println("Sending response to responseChannel")
	transporter.responseChannel <- all
	return nil
}

func (transporter *httpTransporter) getAuthInfo() AuthInfoProvider {
	if transporter.connSettings.authInfo == nil {
		return NoopAuthInfo
	}
	return transporter.connSettings.authInfo
}

func (transporter *httpTransporter) Read() ([]byte, error) {
	fmt.Println("Reading from responseChannel")
	msg, ok := <-transporter.responseChannel
	if !ok {
		return []byte{}, errors.New("failed to read from channel")
	}
	return msg, nil
}

func (transporter *httpTransporter) Close() (err error) {
	fmt.Println("Closing http transporter")
	if !transporter.isClosed {
		if transporter.responseChannel != nil {
			close(transporter.responseChannel)
		}
		transporter.isClosed = true
	}
	return
}

func (transporter *httpTransporter) IsClosed() bool {
	return transporter.isClosed
}
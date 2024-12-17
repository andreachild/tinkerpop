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
	"github.com/gorilla/websocket"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"sync"
	"time"
)

// Transport layer that uses gorilla/websocket: https://github.com/gorilla/websocket
// Gorilla WebSocket is a widely used and stable Go implementation of the WebSocket protocol.
type httpTransporter struct {
	url            string
	httpConnection httpConn
	isClosed       bool
	logHandler     *logHandler
	connSettings   *connectionSettings
	writeChannel   chan []byte
	readChannel    chan []byte
	wg             *sync.WaitGroup
}

type httpConn struct {
	connection net.Conn
}

func (c httpConn) SendMessage(b []byte) ([]byte, error) {
	fmt.Println("Sending message")
	u, _ := url.Parse("http://localhost:8182/gremlin")
	body := io.NopCloser(bytes.NewReader(b))
	req := http.Request{
		Method: "POST",
		URL:    u,
		Header: map[string][]string{
			"content-type": {"application/vnd.graphbinary-v4.0"},
			"host":         {"localhost"},
			"accept":       {"application/vnd.graphbinary-v4.0"},
			//"accept-encoding": {"deflate"},
		},
		Body:          body,
		ContentLength: int64(len(b)),
		//TLS:           nil,
		//TransferEncoding: nil,
	}
	//err := req.Write(c.connection)

	resp, err := http.DefaultClient.Do(&req)
	if err != nil {
		return []byte{}, err
	}
	all, err := io.ReadAll(resp.Body)
	if err != nil {
		return []byte{}, err
	}

	str := hex.EncodeToString(all)

	_, _ = fmt.Fprintf(os.Stdout, "Received response data : %s\n", str)

	return all, nil
}

func (c httpConn) WriteMessage(i int, b []byte) error {
	u, _ := url.Parse("http://localhost:8182/gremlin")
	body := io.NopCloser(bytes.NewReader(b))
	req := http.Request{
		Method: "POST",
		URL:    u,
		Header: map[string][]string{
			"content-type": {"application/vnd.graphbinary-v4.0"},
			"host":         {"localhost"},
			"accept":       {"application/vnd.graphbinary-v4.0"},
			//"accept-encoding": {"deflate"},
		},
		Body:          body,
		ContentLength: int64(len(b)),
		//TLS:           nil,
		//TransferEncoding: nil,
	}
	//err := req.Write(c.connection)

	resp, err := http.DefaultClient.Do(&req)
	if err != nil {
		return err
	}
	all, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	str := hex.EncodeToString(all)

	_, _ = fmt.Fprintf(os.Stdout, "Do response data : %s\n", str)
	return nil
}

func (c httpConn) ReadMessage() (int, []byte, error) {
	// make a temporary bytes var to read from the connection
	tmp := make([]byte, 1024)
	// make 0 length data bytes (since we'll be appending)
	data := make([]byte, 0)
	// keep track of full length read
	length := 0

	// loop through the connection stream, appending tmp to data
	for {
		// read to the tmp var
		n, err := c.connection.Read(tmp)
		if err != nil {
			// log if not normal error
			if err != io.EOF {
				fmt.Printf("Read error - %s\n", err)
			}
			return 2, data, err
		}
		_, err2 := fmt.Fprintf(os.Stdout, "Read %d bytes from connection\n", n)
		if err2 != nil {
			fmt.Println("Error")
			return 0, nil, err2
		}

		slice := tmp[:n]
		str := hex.EncodeToString(slice)
		_, err3 := fmt.Fprintf(os.Stdout, "Data : %s\n", str)
		if err3 != nil {
			fmt.Println("Error")
			return 0, nil, err2
		}

		mark := n
		for i := 0; i < len(slice)-1; i++ {
			if slice[i] == 0xfd && slice[i+1] == 0x00 {
				fmt.Println("Encountered marker")
				mark = i
			}
		}

		// append read data to full data
		data = append(data, tmp[:mark]...)

		// update total read var
		length += n
	}
	//all, err := io.ReadAll(c.connection)
	//return 2, all, err
}

func (c httpConn) SetPongHandler(h func(appData string) error) {

}

func (c httpConn) Close() error {
	fmt.Println("Closing connection")
	return c.connection.Close()
}

func (c httpConn) SetReadDeadline(t time.Time) error {
	return c.connection.SetReadDeadline(t)
}

func (c httpConn) SetWriteDeadline(t time.Time) error {
	return c.connection.SetWriteDeadline(t)
}

// Connect used to establish a connection.
func (transporter *httpTransporter) Connect() (err error) {
	if transporter.httpConnection.connection != nil {
		return
	}
	fmt.Println("Opening connection")
	var u *url.URL
	u, err = url.Parse(transporter.url)
	if err != nil {
		return
	}

	//dialer := &websocket.Dialer{
	//	Proxy:             http.ProxyFromEnvironment,
	//	HandshakeTimeout:  transporter.connSettings.connectionTimeout,
	//	TLSClientConfig:   transporter.connSettings.tlsConfig,
	//	EnableCompression: transporter.connSettings.enableCompression,
	//	ReadBufferSize:    transporter.connSettings.readBufferSize,
	//	WriteBufferSize:   transporter.connSettings.writeBufferSize,
	//}

	d := &net.Dialer{
		Timeout: transporter.connSettings.connectionTimeout,
	}

	header := transporter.getAuthInfo().GetHeader()
	if transporter.connSettings.enableUserAgentOnConnect {
		if header == nil {
			header = make(http.Header)
		}
		header.Set(userAgentHeader, userAgent)
	}

	// Nil is accepted as a valid header, so it can always be passed directly through.
	//conn, _, err := dialer.Dial(u.String(), header)
	hc, err := d.Dial("tcp", u.Host)
	if err != nil {
		return err
	}
	//transporter.connection = conn
	transporter.httpConnection = httpConn{hc}
	transporter.httpConnection.SetPongHandler(func(string) error {
		err := transporter.httpConnection.SetReadDeadline(time.Now().Add(2 * transporter.connSettings.keepAliveInterval))
		if err != nil {
			return err
		}
		return nil
	})
	transporter.wg.Add(1)
	go transporter.writeLoop()
	return
}

// Write used to write data to the transporter. Opens connection if closed.
func (transporter *httpTransporter) Write(data []byte) error {
	if &transporter.httpConnection == nil {
		err := transporter.Connect()
		if err != nil {
			return err
		}
	}
	if len(data) > transporter.connSettings.writeBufferSize {
		return newError(err1201RequestSizeExceedsWriteBufferError)
	}
	transporter.writeChannel <- data
	return nil
}

func (transporter *httpTransporter) getAuthInfo() AuthInfoProvider {
	if transporter.connSettings.authInfo == nil {
		return NoopAuthInfo
	}
	return transporter.connSettings.authInfo
}

func (transporter *httpTransporter) Read() ([]byte, error) {
	fmt.Println("Read Http")
	msg, ok := <-transporter.readChannel
	if !ok {
		return []byte{}, errors.New("failed to read from channel")
	}
	return msg, nil
}

// Close used to close a connection if it is opened.
func (transporter *httpTransporter) Close() (err error) {
	fmt.Println("Closing http")
	if !transporter.isClosed {
		if transporter.writeChannel != nil {
			close(transporter.writeChannel)
		}
		if transporter.wg != nil {
			transporter.wg.Wait()
		}
		err = transporter.httpConnection.Close()
		transporter.isClosed = true
		if err != nil {
			return err
		}
	}
	return
}

// IsClosed returns true when the transporter is closed.
func (transporter *httpTransporter) IsClosed() bool {
	return transporter.isClosed
}

func (transporter *httpTransporter) writeLoop() {
	defer transporter.wg.Done()

	fmt.Println("Http Write loop")
	ticker := time.NewTicker(transporter.connSettings.keepAliveInterval)
	defer ticker.Stop()

	//for {
	select {
	case message, ok := <-transporter.writeChannel:
		if !ok {
			// Channel was closed, we can disconnect and exit.
			return
		}

		// Set write deadline.
		err := transporter.httpConnection.SetWriteDeadline(time.Now().Add(transporter.connSettings.writeDeadline))
		if err != nil {
			transporter.logHandler.logf(Error, failedToSetWriteDeadline, err.Error())
			return
		}

		// Write binary message that was submitted to channel.
		fmt.Println("Writing message")
		//err = transporter.connection.WriteMessage(websocket.BinaryMessage, message)
		resp, err := transporter.httpConnection.SendMessage(message)
		if err != nil {
			transporter.logHandler.logf(Error, failedToWriteMessage, "BinaryMessage", err.Error())
			return
		}
		fmt.Println("Sending response to readChannel")
		transporter.readChannel <- resp
	case <-ticker.C:
		// Set write deadline.
		err := transporter.httpConnection.SetWriteDeadline(time.Now().Add(transporter.connSettings.keepAliveInterval))
		if err != nil {
			transporter.logHandler.logf(Error, failedToSetWriteDeadline, err.Error())
			return
		}

		// Write pong message.
		err = transporter.httpConnection.WriteMessage(websocket.PingMessage, nil)
		if err != nil {
			transporter.logHandler.logf(Error, failedToWriteMessage, "PingMessage", err.Error())
			return
		}
	}
	//}
}

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
	"encoding/base64"
	"fmt"
	"net/http"
)

type httpProtocol struct {
	*protocolBase

	serializer serializer
	logHandler *logHandler
}

// waits for response, deserializes and processes results
// function name is readLoop but is not actually a loop - just keeping the name due to the protocol interface for now
func (protocol *httpProtocol) readLoop(resultSets *synchronizedMap, errorCallback func()) {
	msg, err := protocol.transporter.Read()

	// Deserialize response message
	fmt.Println("Deserializing response")
	resp, err := protocol.serializer.deserializeMessage(msg)
	if err != nil {
		protocol.logHandler.logf(Error, logErrorGeneric, "httpReadLoop()", err.Error())
		readErrorHandler(resultSets, errorCallback, err, protocol.logHandler)
		return
	}

	fmt.Println("Deserialized response")
	// TODO we should not need to use response/request ids to correlate responses with requests anymore after moving from ws to http
	// but for simplicity of http POC we are just setting the responseId to the requestId here
	resp.responseID = protocol.request.requestID
	err = protocol.responseHandler(resultSets, resp)
	if err != nil {
		readErrorHandler(resultSets, errorCallback, err, protocol.logHandler)
		return
	}
}

func newHttpProtocol(handler *logHandler, url string, connSettings *connectionSettings) (protocol, error) {
	transport, err := getTransportLayer(Http, url, connSettings, handler)
	if err != nil {
		return nil, err
	}

	gremlinProtocol := &httpProtocol{
		protocolBase: &protocolBase{transporter: transport},
		serializer:   newGraphBinarySerializer(handler),
		logHandler:   handler,
	}
	return gremlinProtocol, nil
}

// loads results into the response set from the response
func (protocol *httpProtocol) responseHandler(resultSets *synchronizedMap, response response) error {
	fmt.Println("Handling response")

	// TODO http specific response handling - below is just copy-pasted from web socket implementation for now

	responseID, statusCode, metadata, data := response.responseID, response.responseStatus.code,
		response.responseResult.meta, response.responseResult.data
	responseIDString := responseID.String()
	if resultSets.load(responseIDString) == nil {
		return newError(err0501ResponseHandlerResultSetNotCreatedError)
	}
	if aggregateTo, ok := metadata["aggregateTo"]; ok {
		resultSets.load(responseIDString).setAggregateTo(aggregateTo.(string))
	}

	// Handle status codes appropriately. If status code is http.StatusPartialContent, we need to re-read data.
	if statusCode == http.StatusNoContent {
		resultSets.load(responseIDString).addResult(&Result{make([]interface{}, 0)})
		resultSets.load(responseIDString).Close()
		protocol.logHandler.logf(Debug, readComplete, responseIDString)
	} else if statusCode == http.StatusOK {
		// Add data and status attributes to the ResultSet.
		resultSets.load(responseIDString).addResult(&Result{data})
		resultSets.load(responseIDString).setStatusAttributes(response.responseStatus.attributes)
		resultSets.load(responseIDString).Close()
		protocol.logHandler.logf(Debug, readComplete, responseIDString)
	} else if statusCode == http.StatusPartialContent {
		// Add data to the ResultSet.
		resultSets.load(responseIDString).addResult(&Result{data})
	} else if statusCode == http.StatusProxyAuthRequired || statusCode == authenticationFailed {
		// http status code 151 is not defined here, but corresponds with 403, i.e. authentication has failed.
		// Server has requested basic auth.
		authInfo := protocol.transporter.getAuthInfo()
		if ok, username, password := authInfo.GetBasicAuth(); ok {
			authBytes := make([]byte, 0)
			authBytes = append(authBytes, 0)
			authBytes = append(authBytes, []byte(username)...)
			authBytes = append(authBytes, 0)
			authBytes = append(authBytes, []byte(password)...)
			encoded := base64.StdEncoding.EncodeToString(authBytes)
			request := makeBasicAuthRequest(encoded)
			err := protocol.write(&request)
			if err != nil {
				return err
			}
		} else {
			resultSets.load(responseIDString).Close()
			return newError(err0503ResponseHandlerAuthError, response.responseStatus, response.responseResult)
		}
	} else {
		newError := newError(err0502ResponseHandlerReadLoopError, response.responseStatus, statusCode)
		resultSets.load(responseIDString).setError(newError)
		resultSets.load(responseIDString).Close()
		protocol.logHandler.logf(Error, logErrorGeneric, "httpProtocol.responseHandler()", newError.Error())
	}
	return nil
}

// serializes and sends the request
func (protocol *httpProtocol) write(request *request) error {
	protocol.request = request
	// TODO interceptors
	fmt.Println("Serializing request")
	bytes, err := protocol.serializer.serializeMessage(request)
	if err != nil {
		return err
	}
	return protocol.transporter.Write(bytes)

}

func (protocol *httpProtocol) close(wait bool) error {
	return nil
}

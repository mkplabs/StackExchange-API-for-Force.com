/**
 * Copyright (c) 2014, MK Partners, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of MK Partners, Inc. nor the names of its contributors
 *		nor the MKP Labs brand nor the www.mkpartners.com URL nor the www.mkplabs.com URL  
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public with sharing class testHttpCalloutMock implements HttpCalloutMock {
	
	//A single method that acts as a webservice to simulate 3rd party services
	public HTTPResponse respond(HTTPRequest req){
		//Look at the httpRequest that was sent via Apex to possibly determine how we will respond
		system.debug(req.getBody());
		system.debug(req.getMethod());
		system.debug(req.getEndpoint());

		//Construct the object that we want to respond with
		stackExchangeAPI.responseResource response = new stackExchangeAPI.responseResource();

		response.items = new List<stackExchangeAPI.questionResource>{new stackExchangeAPI.questionResource()};
		response.items[0].tags = new List<String>{'test'};
		response.items[0].is_answered = true;
		response.items[0].view_count = 0;
		response.items[0].answer_count = 0;
		response.items[0].score = 100;
		response.items[0].last_activity_date = system.now().getTime();
		response.items[0].creation_date = system.now().getTime();
		response.items[0].last_edit_date = system.now().getTime();
		response.items[0].question_id = 1;
		response.items[0].link = 'Test Link';
		response.items[0].title = 'Test Title';
		
		response.items[0].owner = new stackExchangeAPI.userResource();
		response.items[0].owner.reputation = 'Test';
		response.items[0].owner.user_id = 'Test';
		response.items[0].owner.user_type = 'Test';
		response.items[0].owner.profile_image = 'Test';
		response.items[0].owner.display_name = 'Test';
		response.items[0].owner.link = 'Test';

		//Instantiate a new httpResponse
		httpResponse res = new httpResponse();

		//Set the Status
		res.setStatus('OK');

		//Set the StatusCode
		res.setStatusCode(200);

		//Set the Body to the serialized form of the instance of the stackExchangeAPI.responseResource
		res.setBody(JSON.serialize(response));

		//Return the httpResponse
		return res;
	}

}
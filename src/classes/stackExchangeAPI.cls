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

public with sharing class stackExchangeAPI {
	public static String BASE_URL = 'https://api.stackexchange.com/2.2/';

	//Method to perform a callout and return an httpResponse
	public static httpResponse callout(String httpMethod, String endpoint, String body){
		//Instantiate an httpRequest and set the required attributes
		httpRequest req = new httpRequest();
		req.setMethod(httpMethod);
		req.setEndpoint(endpoint);

		//Optional attributes are often required to conform to the 3rd Party Web Service Requirements
		req.setHeader('Accept-Encoding','gzip, deflate');

		//You can adjust the timeout duration (in milliseconds) to deal with slow servers or large payloads
		req.setTimeout(120000);

		//Use the HTTP Class to send the httpRequest and receive an httpResposne
		/*If you are not using an HttpCalloutMock: 
		if (!test.isRunningTest){
		*/
		httpResponse res = new http().send(req);
		/*If you are not using an HttpCalloutMock: 
		}
		*/
		system.debug(res.toString());
		system.debug(res.getBody());
		return res;
	}

	//Method to deserialize the response body
	public static responseResource deserialize(httpResponse res){
		return (responseResource)JSON.deserialize(res.getBody(),responseResource.class);
	}

/********************* Apex Inner Classes to represent StackExchange objects ***********************/

	//Outermost class included in the response from StackExchange
	public class responseResource {
		public Integer error_id {get;set;}
		public String error_message {get;set;}
		public String error_name {get;set;}
		public Boolean hasMore {get;set;}
		public List<questionResource> items {get;set;}
		public Integer quote_max {get;set;}
		public Integer quote_remaining {get;set;}
	}

	//Class to represent a question posted on StackExchange
	public class questionResource {
		public List<String> tags {get;set;}
		public userResource owner {get;set;}
		public Boolean is_answered {get;set;}
		public Integer view_count {get;set;}
		public Integer answer_count {get;set;}
		public Integer score {get;set;}
		public long last_activity_date {get;set;}
		public long creation_date {get;set;}
		public long last_edit_date {get;set;}
		public integer question_id {get;set;}
		public String link {get;set;}
		public String title {get;set;}
	}

	//Class to represent a registered User of StackExchange
	public class userResource {
		public String reputation {get;set;}
		public String user_id {get;set;}
		public String user_type {get;set;}
		public String profile_image {get;set;}
		public String display_name {get;set;}
		public String link {get;set;}
	}


/********************* Other Useful Methods ***********************/

	// http://api.stackexchange.com/2.2/questions/unanswered?page=1&pagesize=50&fromdate=1396310400&todate=1398816000&order=desc&min=1396310400&max=1397606400&sort=activity&tagged=google-compute-engine&site=stackoverflow
	public static responseResource questions_Unanswered(String site, Integer page, Integer pagesize, Date fromdate, Date todate, String order, Date min, Date max, String sortParam, String tagged){
		httpResponse res = callout('GET', compileEndpoint('questions/unanswered',site,page,pagesize,fromdate,todate,order,min,max,sortParam,tagged) , null);
		if ( res.getStatusCode() == 200 && string.isNotBlank(res.getBody()) ){
			return deserialize(res);
		}
		return null;
	}

	public static String compileEndpoint(String call, String site, Integer page, Integer pagesize, Date fromdate, Date todate, String order, Date min, Date max, String sortParam, String tagged){
		PageReference endpoint = new PageReference(BASE_URL+call);
		if ( string.isNotBlank(site) ){
			endpoint.getParameters().put('site',site);
		}
		if ( page != null && page > 0 ){
			endpoint.getParameters().put('page',string.valueOf(page));
		}
		if ( pagesize != null ){
			endpoint.getParameters().put('pagesize',string.valueOf(pagesize));
		}
		if ( fromdate != null ){
			endpoint.getParameters().put('fromdate',string.valueOf(dateTime.newInstance(fromdate,time.newInstance(0,0,0,0)).getTime()/1000));
		}
		if ( todate != null ){
			endpoint.getParameters().put('todate',string.valueOf(dateTime.newInstance(todate,time.newInstance(0,0,0,0)).getTime()/1000));
		}
		endpoint.getParameters().put('order','desc');
		if ( string.isNotBlank(order) ){
			endpoint.getParameters().put('order',order);
		}
		if ( min != null ){
			endpoint.getParameters().put('min',string.valueOf(dateTime.newInstance(min,time.newInstance(0,0,0,0)).getTime()/1000));
		}
		if ( max != null ){
			endpoint.getParameters().put('max',string.valueOf(dateTime.newInstance(max,time.newInstance(0,0,0,0)).getTime()/1000));
		}
		endpoint.getParameters().put('sort','activity');
		if ( string.isNotBlank(sortParam) ){
			endpoint.getParameters().put('sort',sortParam);
		}
		if ( string.isNotBlank(tagged) ){
			endpoint.getParameters().put('tagged',tagged);
		}
		return endpoint.getURL();
	}


}
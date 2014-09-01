//
//  CommanConstants.h
//  EWN
//
//  Created by Macmini on 22/04/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
/**------------------------------------------------------------------------
 File Name      : CommanConstants.h
 Created By     : Arpit Jain
 Created Date   : 
 Purpose        : All constants to be used in the project should be defined in this file.
 -------------------------------------------------------------------------*/

#ifndef EWN_CommanConstants_h
#define EWN_CommanConstants_h

#pragma mark -
#pragma mark SplashScreenViewController Constants.

#define kShowAdsBOOL YES
#define version2 YES
#define kTotal_Pages 5

#define kHostName @"http://ewn.co.za/services/ewn_webservices_v2.asmx"
#define kstrLeadingNews @"LeadingNews"
#define kstrImgLoader_1 @"loader_1.png"
#define kstrImgLoader_2 @"loader_2.png"
#define kstrImgLoader_3 @"loader_3.png"
#define kstrImgLoader_4 @"loader_4.png"
#define kstrImgLoader_5 @"loader_5.png"
#define kstrImgLoader_6 @"loader_6.png"
#define kstrImgLoader_7 @"loader_7.png"
#define kstrImgLoader_8 @"loader_8.png"
#define kstrImgLoader_9 @"loader_9.png"
#define kstrImgLoader_10 @"loader_10.png"
#define kstrImgLoader_11 @"loader_11.png"
#define kPushNotificationName @"APP_OFFLINE_FIRST_LAUNCH"
#define kPushNotificationForStoryButton @"Failur_To_Load_Story"
#define kPushNotificationForTimeLineButton @"Failur_To_Load_TimeLine"
#define kImgNameDefault @"Image_Default.png"

#define kImageFolder @"images"

#pragma mark - ContentListView Constants
#define kNOTIFICATION_VIDEOS @"GotVideos"
#define kNOTIFICATION_IMAGES @"GotImages"
#define kNOTIFICATION_AUDIO @"GotAudio"
#define kNOTIFICATION_ARTICLES @"GotArtilces"

#define kNOTIFICATION_INIT_RELATED @"INITIATERELATED"
#define kNOTIFICATION_RELOAD_RELATED @"GotRelatedStories"

#define kNOTIFICATION_INIT_STORYTIME @"INITIATE_STORYLINE"
#define kNOTIFICATION_RELOAD_STORYTIME @"RELOAD_STORYLINE"
#define kNOTIFICATION_INIT_LOAD_PROGRESS @"INIT_LOAD_PROGRESS"
#define kNOTIFICATION_SIGN_OUT @"SIGN_OUT"

#define kNOTIFICATION_BREAKING_NEWS_FROM_NOTIFICATION @"BREAKING_NEWS_FROM_ALERT"
#define kNOTIFICATION_BREAKING_NEWS_FROM_NOTIFICATION_DISPLAY @"BREAKING_NEWS_FROM_ALERT_DISPLAY"
#define kNOTIFICATION_CLOSE_CONTRIBUTE_TERMS @"CLOSE_CONTRIBUTE_TERMS"

#define kNOTIFICATION_LIGHTBOX_IMAGE @"LIGHTBOX_IMAGE"

#pragma mark -
#pragma mark NewsListViewController Constants.

#define kEntityCategory @"Category_Items"
#define kEntityInFocus @"InFocus_Items"
#define kEntityContents @"Contents"
#define kEntityContentContents @"ContentContents"
#define kEntityLeadingNews @"LeadingNews"
#define kEntityMasterContentCategory @"MasterContentCategory"
#define kEntityRelatedStory @"RelatedStoryAndTimeline"
#define kEntityComments @"Comments"
#define kEntityCommentReplies @"CommentReplies"
#define kstrRelated @"related"
#define kstrTimeline @"timeline"
#define kstrLatest @"latest"
#define kstrVideo @"video"
#define kstrImages @"images"
#define kstrAudio @"audio"
#define kstrImgToolbar @"toolbarBack.png"
#define kstrCurrentCategory @"CurrentCategory"
#define kContentImages @"image"
#define kcontentLatest @"newsarticle"

#define kCONTENT_TITLE_LATEST   @"articles"
#define kCONTENT_TITLE_VIDEO    @"videos"
#define kCONTENT_TITLE_IMAGE    @"images"
#define kCONTENT_TITLE_AUDIO    @"audio"

#define kCONTENT_TITLE_SEARCH    @"Search"

#define kTITLE_LABEL_TAG_OFFSET 10000

#define kTITLE_CURRENT_PAGE_X       5
#define kTITLE_SINGLE_TRANSITION    0.15625
#define kTITLE_NEXT_PAGE_X          40

#define kIN_FOCUS_LIMIT 3

/* FONTS */
#define kFontOpenSansRegular @"OpenSans"
#define kFontOpenSansBold @"OpenSans-Bold"
#define kFontOpenSansSemiBold @"OpenSans-Semibold"
#define kFontOpenSansLight @"OpenSans-Light"

#pragma mark -
#pragma mark Webservice Constants.

//#define kDEV_Url @"http://labs.ewn.co.za/services/ewn_webservices_v2.asmx" // DEV 2.0
//#define kLIVE_Url @"http://ewn.co.za/services/ewn_webservices_v2.asmx" // LIVE 2.0

//#define kLIVE_Url @"http://lab.ewn.co.za/services/EWN_Webservices_v2_1.asmx" // DEV 2.1
//#define kLIVE_Url @"http://ewn.co.za/services/ewn_webservices_v2_1.asmx" // LIVE 2.1

//#ifdef DEBUG
//#define kLIVE_Url @"http://lab.ewn.co.za/services/EWN_Webservices_v2_2.asmx" // DEV 2.2
//#define kLIVE_Url @"http://41.168.20.230/services/EWN_Webservices_v2_2.asmx" // DEV 2.2 by ip
//#else
#define kLIVE_Url @"http://ewn.co.za/services/ewn_webservices_v2_2.asmx" // LIVE 2.2
//#endif

//Soap Tags
#define kCategory 1
#define kLeadingNews 2
#define kLatestNews 3
#define kVideo 4 
#define kImages 5 
#define kAudio 6
#define kSearchNews 7
#define kStoryTimeline 8
#define kRelatedStory 9
#define kBreakingNews 10
#define kURLChecking 11
#define kAllNews 12
/* CONTEXT MENU API REQUESTS */
#define kWeatherTag 13
#define kBulletinTag 14
#define kTrafficTag 15
#define kCommentsTag 16
#define kAuthenticate 17
#define kPostCommentTag 18
#define kPostFeedbackTag 19
#define kInFocus 20
#define kInFocusNews 21
#define kReportCommentTag 22
#define kLikeCommentTag 23
#define kReplyCommentTag 24
/* breaking news from a notification */
#define kBreakingNewsFromAlert 25
#define kContentItem 26
#define kMarketCurrencyTag 27
#define kMarketCommodityTag 28
#define kTerms 29
#define kContributeKeyTag 30
#define kContributeTag 31
#define kContributeFileTag 32

#define kExpireValidityOfCategory 7*24*60*60 // 7 days with craig david
#define kExpireValidityOfInFocus 60*60*24*7 // 7 days for now = 1 hour
#define kExpireValidityOfStory 60*60
#define kRequestExpire 10*60 // 10*60
#define kRequestCommentExpire 60 // 1 minute
#define kRequestTimeout 30
#define kALERT_TAG_NO_CONNECTION 201
#define kALERT_TAG_BREAKING_NEWS 202
#define kALERT_TAG_ACTIVE_CONNECTION 203
#define kALERT_TAG_NO_NEWS_DATA 204
#define kALERT_TAG_SIGN_OUT 205
#define kALERT_TAG_BREAKING_NEWS_FROM_NOTIFICATION 206
#define kALERT_TAG_CONTRIBUTE 207
#define kALERT_TAG_CONTRIBUTEKEY 208
#define kALERT_TAG_CONTRIBUTESUBMISSION 209
#define kALERT_TAG_INTERNAL_SERVER_ERROR 500
// OVER HERE
#define kDefaultBatchCount 20 // 20

#define kDefaultBatchCountFirstPage (kDefaultBatchCount + 1)
#define kstrKeyForAllNews @"001-AllNews"
#define kstrAllNews @"All News"

/* GENERAL API REQUESTS */
#define kStartDate @"0001-01-01T00:00:00"

#define kSoapMessageTerms @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetTermsAndConditions/></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageAuthenticate @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:AuthenticateUserByToken><!--Optional:--><tem:janrainToken>%@</tem:janrainToken></tem:AuthenticateUserByToken></soapenv:Body></soapenv:Envelope>";

#define kSoapMessageCategory @"<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:tem=\"http://tempuri.org/\"><soap:Header/><soap:Body><tem:GetCategories/></soap:Body></soap:Envelope>"

#define kSoapMessageInFocus @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetInfocusItems xmlns=\"http://tempuri.org/\"/></soap:Body></soap:Envelope>"

#define kSoapMessageBreakingNews @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetBreakingNews/></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageContentItem @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetContentItem><tem:contentItemId>%@</tem:contentItemId></tem:GetContentItem></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageLeadingNews @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetLeadingNews/></soapenv:Body></soapenv:Envelope>"
#define kSoapMessageLeadingNewsForCategory @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetLeadingNews><tem:categoryid>%@</tem:categoryid></tem:GetLeadingNews></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageLatestNews_Video_Images_Audio @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetLatestNewsByCategoryAndContentType><!--Optional:--><tem:categoryId>%@</tem:categoryId><!--Optional:--><tem:contentType>%@</tem:contentType><tem:itemsPerPage>%d</tem:itemsPerPage><tem:pageNumber>%d</tem:pageNumber><tem:getItemsUpdatedSince>%@</tem:getItemsUpdatedSince><tem:getItemsPublishedBefore>%@</tem:getItemsPublishedBefore></tem:GetLatestNewsByCategoryAndContentType></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageInFocusNews @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetLatestNewsByInfocusItem xmlns=\"http://tempuri.org/\"><infocusItemId>%@</infocusItemId><itemsPerPage>%d</itemsPerPage><pageNumber>%d</pageNumber><getItemsUpdatedSince>%@</getItemsUpdatedSince></GetLatestNewsByInfocusItem></soap:Body></soap:Envelope>"

#define kSoapMessageStoryTimeLineByArticleId @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetStoryTimelineByArticleId><!--Optional:--><tem:articleId>%@</tem:articleId><tem:itemsPerPage>%d</tem:itemsPerPage><tem:pageNumber>%d</tem:pageNumber></tem:GetStoryTimelineByArticleId></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageNews_Search_All @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetLatestNewsByKeyword><!--Optional:--><tem:keyword>%@</tem:keyword><!--Optional:--><tem:itemsPerPage>%d</tem:itemsPerPage><tem:pageNumber>%d</tem:pageNumber></tem:GetLatestNewsByKeyword></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageNews_Search @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetLatestNewsByKeywordAndCategory><!--Optional:--><tem:categoryId>%@</tem:categoryId><!--Optional:--><tem:keyword>%@</tem:keyword><tem:itemsPerPage>%d</tem:itemsPerPage><tem:pageNumber>%d</tem:pageNumber></tem:GetLatestNewsByKeywordAndCategory></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageNewsContentType_Search @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetLatestNewsByKeywordAndContentType><!--Optional:--><tem:keyword>%@</tem:keyword><!--Optional:--><tem:contentType>%@</tem:contentType><tem:itemsPerPage>%d</tem:itemsPerPage><tem:pageNumber>%d</tem:pageNumber><tem:getItemsUpdatedSince>%@</tem:getItemsUpdatedSince></tem:GetLatestNewsByKeywordAndContentType></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageNewsCategoryAndContentType_Search @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetLatestNewsByKeywordAndCategoryAndContentType><!--Optional:--><tem:categoryId>%@</tem:categoryId><!--Optional:--><tem:keyword>%@</tem:keyword><!--Optional:--><tem:contentType>%@</tem:contentType><tem:itemsPerPage>%d</tem:itemsPerPage><tem:pageNumber>%d</tem:pageNumber><tem:getItemsUpdatedSince>%@</tem:getItemsUpdatedSince></tem:GetLatestNewsByKeywordAndCategoryAndContentType></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageAllNews @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetLatestNewsByContentType><!--Optional:--><tem:contentType>%@</tem:contentType><tem:itemsPerPage>%d</tem:itemsPerPage><tem:pageNumber>%d</tem:pageNumber><tem:getItemsUpdatedSince>%@</tem:getItemsUpdatedSince><tem:getItemsPublishedBefore>%@</tem:getItemsPublishedBefore></tem:GetLatestNewsByContentType></soapenv:Body></soapenv:Envelope>"

#define kSoapMessageRelatedStoryByArticleId @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetRelatedStoriesByArticleId><!--Optional:--><tem:articleId>%@</tem:articleId><tem:itemsPerPage>%d</tem:itemsPerPage><tem:pageNumber>%d</tem:pageNumber></tem:GetRelatedStoriesByArticleId></soapenv:Body></soapenv:Envelope>"

#define kRequestWeather @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetWeatherFeed xmlns=\"http://tempuri.org/\"/></soap:Body></soap:Envelope>"

#define kPostComment @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:SubmitComment><!--Optional:--><tem:articleId>%@</tem:articleId><!--Optional:--><tem:userId>%@</tem:userId><!--Optional:--><tem:commentText>%@</tem:commentText></tem:SubmitComment></soapenv:Body></soapenv:Envelope>";

#define kPostFeedback @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><SubmitFeedback xmlns=\"http://tempuri.org/\"><feedbackText>%@</feedbackText></SubmitFeedback></soap:Body></soap:Envelope>"

// cityName
#define kRequestWeatherForCity @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetWeatherForCity xmlns=\"http://tempuri.org/\"><cityName>%@</cityName></GetWeatherForCity></soap:Body></soap:Envelope>"

#define kRequestBulletins @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetAudioBulletins xmlns=\"http://tempuri.org/\"/></soap:Body></soap:Envelope>"

#define kRequestTraffic @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetTrafficFeed xmlns=\"http://tempuri.org/\"/></soap:Body></soap:Envelope>"

#define kRequestMarketCurrency @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetCurrenciesData/></soapenv:Body></soapenv:Envelope>"

#define kRequestMarketCommodity @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetCommoditiesData/></soapenv:Body></soapenv:Envelope>"

// articleId, itemsPerPage, pageNumber
#define kRequestComments @"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetAllComments xmlns=\"http://tempuri.org/\"><articleId>%@</articleId><itemsPerPage>%d</itemsPerPage><pageNumber>%d</pageNumber></GetAllComments></soap:Body></soap:Envelope>"

#define kRequestReportComment @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:ReportComment><tem:commentId>%@</tem:commentId></tem:ReportComment></soapenv:Body></soapenv:Envelope>"

#define kRequestLikeComment @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:LikeComment><tem:commentId>%@</tem:commentId><tem:userId>%@</tem:userId><tem:likeComment>%@</tem:likeComment></tem:LikeComment></soapenv:Body></soapenv:Envelope>"

#define kRequestSubmitReply @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:SubmitReply><tem:commentId>%@</tem:commentId><tem:userId>%@</tem:userId><tem:commentText>%@</tem:commentText></tem:SubmitReply></soapenv:Body></soapenv:Envelope>"

#define kRequestContributeKey @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:GetSubmissionSessionKey/></soapenv:Body></soapenv:Envelope>"

#define kRequestContribute @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:PostSubmission><tem:sessionKey>%@</tem:sessionKey><tem:title>%@</tem:title><tem:story>%@</tem:story><tem:commentToEditor></tem:commentToEditor><tem:submitterName>%@</tem:submitterName><tem:submitterEmail>%@</tem:submitterEmail><tem:submitterContact></tem:submitterContact><tem:submitterTwitter></tem:submitterTwitter></tem:PostSubmission></soapenv:Body></soapenv:Envelope>"

#define kRequestContributeFile @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\"><soapenv:Header/><soapenv:Body><tem:PostSubmissionFileByURL><tem:fileURL>%@</tem:fileURL><tem:sessionKey>%@</tem:sessionKey></tem:PostSubmissionFileByURL></soapenv:Body></soapenv:Envelope>"

#define kRequestShare @""

//Soap Actions
#define kSoapActionContributeKey @"http://tempuri.org/GetSubmissionSessionKey"
#define kSoapActionContribute @"http://tempuri.org/PostSubmission"
#define kSoapActionContributeFile @"http://tempuri.org/PostSubmissionFileByURL"

#define kSoapActionAuthenticate @"http://tempuri.org/AuthenticateUserByToken"

#define kSoapActionCategory @"http://tempuri.org/GetCategories"
#define kSoapActionInFocus @"http://tempuri.org/GetInfocusItems"

#define kSoapActionBreakingNews @"http://tempuri.org/GetBreakingNews"
#define kSoapActionTerms @"http://tempuri.org/GetTermsAndConditions"
#define kSoapActionGetContentItem @"http://tempuri.org/GetContentItem"

#define kSoapActionLeadingNews @"http://tempuri.org/GetLeadingNews"
#define kSoapActionLatestNews_Video_Images_Audio @"http://tempuri.org/GetLatestNewsByCategoryAndContentType"
#define kSoapActionInFocusNews @"http://tempuri.org/GetLatestNewsByInfocusItem"
#define kSoapActionNews_Search @"http://tempuri.org/GetLatestNewsByKeywordAndCategory"
#define kSoapActionNews_SearchALL @"http://tempuri.org/GetLatestNewsByKeyword"
#define kSoapActionNewsContentType_Search @"http://tempuri.org/GetLatestNewsByKeywordAndContentType"
#define kSoapActionNewsCategoryAndContentType_Search @"http://tempuri.org/GetLatestNewsByKeywordAndCategoryAndContentType"

#define kSoapActionStoryTimeline @"http://tempuri.org/GetStoryTimelineByArticleId"
#define kSoapActionRelatedStory @"http://tempuri.org/GetRelatedStoriesByArticleId"
#define kSoapActionAllNews @"http://tempuri.org/GetLatestNewsByContentType"

#define kSoapActionWeather @"http://tempuri.org/GetWeatherFeed"
#define kSoapActionBulletin @"http://tempuri.org/GetAudioBulletins"
#define kSoapActionTraffic @"http://tempuri.org/GetTrafficFeed"
#define kSoapActionComments @"http://tempuri.org/GetAllComments"

#define kSoapActionPostComment @"http://tempuri.org/SubmitComment"
#define kSoapActionPostFeedback @"http://tempuri.org/SubmitFeedback"

#define kSoapActionReportComment @"http://tempuri.org/ReportComment"
#define kSoapActionLikeComment @"http://tempuri.org/LikeComment"
#define kSoapActionSubmitReply @"http://tempuri.org/SubmitReply"

#define kSoapActionMarketCurrency @"http://tempuri.org/GetCurrenciesData"
#define kSoapActionMarketCommodity @"http://tempuri.org/GetCommoditiesData"

#define kMsgNoNewsData @"You do not have news for section, all news has been loaded."

// User default

#define kDateForDeleteCategoryCache @"DeleteCategoryFromDB"
#define kDateForDeleteInFocusCache @"DeleteInFocusFromDB"
#define kDateForDeleteStoryCache @"DeleteStoriesFromDB"

//Flurry Analytics Constants
#define kFLURRY_API_KEY @"M3DZTNZ4GXQ55YYKNW8P"

#define KFlurryEventCategorySwitched @"Category_Switched"
#define KFlurryEventArticleViewed @"Article_Viewed"
#define KFlurryEventContentTypeViewed @"Contenttype_Viewed"
#define KFlurryEventKeyWordSearched @"Keyword_Searched"
#define KFlurryEventTimeline_RelatedStorySwitching @"StoryTimeline_RelatedStory_Switching"
#define KFlurryEventNewsListPaging @"NewsList_Paging"
#define KFlurryEventBreakingNewsRead @"BreakingNews_Read"

///Video/Audio streaming URL

#define kStreamingVideoURL @"http://www.pod702.co.za/Eyewitnessnews/video/"
#define kStreamingAudioURL @"http://www.pod702.co.za/Eyewitnessnews/audio/"

// cachedata constants

#define kstrCategoryIndex @"categoryIndex"
#define kstrId @"Id"
#define kstrName @"Name"
#define kstrCreatedDate @"createdDate"
//#define kstrContentType @"ContentType"
#define kstrContentIndex @"contentIndex"
#define kstrBodyText @"BodyText"
#define kstrArticleId @"ArticleId"
#define kstrArticleID @"ArticleID"
#define kstrCartoon @"Cartoon"
#define kstrDateAdded @"DateAdded"
#define kstrFeaturedImageUrl @"FeaturedImageUrl"
#define kstrFlvOnly @"FlvOnly"
#define kstrImageLargeURL @"ImageLargeURL"
#define kstrIntroParagraph @"IntroParagraph"
#define kstrIsBreakingNews @"IsBreakingNew  s"
#define kstrIsLeadStory @"IsLeadStory"
#define kstrPostRoll @"PostRoll"
#define kstrPublishDate @"PublishDate"
#define kstrTitle @"Title"
#define kstrURL @"URL"
#define kstrPreRoll @"PreRoll"
#define kstrImageUrl @"ImageUrl"
#define kstrThumbnilImageUrl @"ThumbnilImageUrl"
#define kstrImageThumbnailURLData @"ImageThumbnailURLData"
#define kstrFeaturedImageUrlData @"FeaturedImageUrlData"
#define kstrCaption @"Caption"
#define kstrCaptionShort @"CaptionShort"
#define kstrAuthor @"Author"
#define kstrPeopleAlsoRead @"PeopleAlsoRead"
#define kstrHashtag @"Hashtag"
#define kstrStoryIndex @"storyIndex"
#define kstrThumbnilImageUrlData @"ThumbnilImageUrlData"
#define kstrCategory @"Category"
#define kstrCategories @"Categories"
#define kstrAttachedMedia @"AttachedMedia"
#define kstrParentID @"ParentID"
#define kstrContentItems @"ContentItems"
#define kstrContentItem @"ContentItem"
#define kstrContentType @"Content_type"
#define kstrImageThumbnailURL @"ImageThumbnailURL"
#define kstrContentsListViewController_iPhone5 @"ContentsListViewController_iPhone5"
#define kstrContentsListViewController @"ContentsListViewController"

// Contact
#define kstrContactViewController_iPhone5 @"ContactViewController_iPhone5"
#define kstrContactViewController @"ContactViewController"

#define kTypeCall       @"phone"
#define kTypeSms        @"sms"
#define kTypeEmail      @"email"
#define kTypeFax        @"fax"

#define kTypeFacebook   @"facebook"
#define kTypeTwitter    @"twitter"
#define kTypeYoutube    @"youtube"
#define kTypePinterest  @"pinterest"

#define kNOTIFICATION_POST_FEEDBACK @"GotFeedback"

// Contribute
#define kstrContributeViewController_iPhone5 @"ContributeViewController_iPhone5"
#define kstrContributeViewController @"ContributeViewController"

// Settings
#define kstrSettingsViewController_iPhone5 @"SettingsViewController_iPhone5"
#define kstrSettingsViewController @"SettingsViewController"

//content list view constants

#define kstrCategoryName @"CategoryName"

#define kNOTIFICATION_AUTHENTICATE @"GotAuth"
#define kNOTIFICATION_POST_COMMENT @"GotComment"

//search news list view.

#define kstrContentDetailViewController_iPhone5 @"ContentDetailViewController_iPhone5"
#define kstrContentDetailViewController @"ContentDetailViewController"
#define kstrPleaseWaitLoadingData @"Please Wait, Loading Data..."
#define kstrNoTimelineData @"There are currently no news releases in this story timeline"
//contentDetailview constants

#define kstrStoryTimelineViewController_iPhone5 @"StoryTimelineViewController_iPhone5"
#define kstrStoryTimelineViewController @"StoryTimelineViewController"
#define kstrThumbnailImageUrlData @"ThumbnailImageUrlData"
#define kstrError @"Error"
#define kstrFileIsNotFound @"File is not found."
#define kstrUnknownError @"Unknown error"
#define kstrNoNewsData @"No News"
#define kstrErrorPlaying @"Content not playable at this time."

#define kstrFilename @"Filename"

//main view constants

#define kstrNewsListViewController_iPhone5 @"NewsListViewController_iPhone5"
#define kstrArticleMasterViewController_iPhone5 @"ArticleDetailMaster_iPhone5"
#define kstrArticleMasterViewController @"ArticleDetailMaster"
#define kstrNewsListViewController @"NewsListViewController"
#define kstrSideMenuViewController_iPhone5 @"SideMenuViewController_iPhone5"
#define kstrSideMenuViewController_iPhone @"SideMenuViewController_iPhone"
#define kstrCategoryId @"CategoryId"
#define kstrShow @"Show"
#define kstrPleaseWaitCategories @"Please Wait, Loading Categories..."

//Side menu constants

#define kstrSearchNewsListViewController_iPhone5 @"SearchNewsListViewController_iPhone5"
#define kstrSearchNewsListViewController @"SearchNewsListViewController"
#define kstrSECTIONS @"SECTIONS"
#define kstrCATEGORIES @"CATEGORIES"
#define kstrFOCUS @"In Focus"
#define kstrLATESTNEWS @"LATEST NEWS"
#define kstrVIDEOGALLERY @"VIDEO GALLERY"
#define kstrIMAGEGALLERY @"IMAGE GALLERY"
#define kstrAUDIONEWS @"AUDIO NEWS"
#define kstrSearchNews @"Search News"
#define kstrNoNewsFound @"There are no results in the %@ category. Please refine your search."

// Context Menu Constants

#define kContextMenuPadding 100
#define kContentListOptions @"contentList"
#define kContentDetailOptions @"contentDetail"
#define kSearchOptions @"searchOptions"
#define kSearchOptionsNoFocus @"searchOptionsNoFocus"

// Context Page Constants

#define kContextPageTitleHeight 30
#define kContextPageMenuHeight 30

// Comments Constants
#define kCommentLimit 3
#define kCommentAll 0

//common utilities constants

#define kstryyyy_MM_dd_T_HH_mm_ss_Z @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#define kstryyyy_MM_dd_T_HH_mm_ss_SSS_Z @"yyyy-MM-dd'T'HH:mm:ss.SSS 'Z'"

//search view controller constants

#define kstrStoryTimeline @"Story Timeline"
#define kstrRelatedStory @"Related Story"
#define kstrPleaseWaitSearchingNews @"Please Wait, Searching news..."
#define kstrPleaseEnterKeyword @"The search term is less than three characters."

//Webservice constants

#define kstrNewsArticlesOnly @"NewsArticlesOnly"
#define kstrBREAKINGNEWS @"BREAKING NEWS"

//Splash screen constants

#define kstrMainViewController_iPhone5 @"MainViewController_iPhone5"
#define kstrMainViewController_iPhone @"MainViewController_iPhone"

//appDelegate Constants

#define kstrSplashScreenViewController_iPhone5 @"SplashScreenViewController_iPhone5"
#define kstrSplashScreenViewController_iPhone @"SplashScreenViewController_iPhone"

//custom alertview constants

#define kstrCustomAlertView @"CustomAlertView" 
#define kstrConnectionError @"Connection error"
#define kstrNoStoryTimelineData @"Story TimeLine"
#define kstrNoRelaatedData @"Related Story"

#define kstrConnectionRegained @"You regained your internet connection. Would you like to reload your data?"
#define kstrNoConnectionMessage @"Sorry you have no internet connection, Please check your connection and try again.\nTap Home Button to close the app."
#define kstrNoConnectionButHaveCacheDataMessage @"You do not have an active internet connection, you can only view offline data.\nTo view offline data, Tap OK.\nTap Home Button to close the app."
#define kstrNoRelatedDataMessage @"There are currently no related news articles with this release."
#define kstrNoStoryTimeLinedDataMessage @"There are currently no news releases in this story timeline."
#define kstrNoRelatedStoryDataMessage @"There are currently no news releases in this related stories."

#define kstrInternalServerError @"Internal Server Error"
#define kstrInternalServerErrorMessage @"Please exit the app and restart the app."
#define kstrTimeout @"Server Timed Out"
#define kstrTimeoutStartupMessage @"Server timed out, please try again later."

// WebAPIRequest Error Types
#define kErrorResponse @"repsonse"
#define kErrorTimeout @"timeout"

//flurry
#define kstrSearchedtext @"Searchedtext"

#pragma mark - Side Menu Constants
/**-----------------------------------------------------------------
                    Side Menu Constants
 ------------------------------------------------------------------*/

#define kUICOLOR_SIDEMNU_HEADER [UIColor colorWithRed:(40.0/255.0) green:(40.0/255.0) blue:(40.0/255.0) alpha:1.0]
#define kUICOLOR_SIDEMNU_BACK [UIColor colorWithRed:(50.0/255.0) green:(50.0/255.0) blue:(50.0/255.0) alpha:1.0]
#define kUICOLOR_SIDEMNU_BACK_HIGHLIGHT [UIColor colorWithRed:(60.0/255.0) green:(60.0/255.0) blue:(60.0/255.0) alpha:1.0]
#define kUICOLOR_RELATED_BACK [UIColor colorWithRed:(50.0/255.0) green:(50.0/255.0) blue:(50.0/255.0) alpha:1.0]
#define kUICOLOR_LIGHT_GRAY [UIColor colorWithRed:(215.0/255.0) green:(215.0/255.0) blue:(215.0/255.0) alpha:1.0]

/*-----------------------------------------------------------------*/

#pragma mark - Search News View Constants
/**-----------------------------------------------------------------
 Search News View Constants
 ------------------------------------------------------------------*/

#define  kDATEFORMATE_SEARCH_NEWS @"dd-MMM-yyyy"

/*-----------------------------------------------------------------*/



#endif


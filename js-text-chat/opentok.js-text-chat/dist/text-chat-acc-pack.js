var OTKAnalytics=function(){var e=function(e){this.url="https://hlg.tokbox.com/prod/logging/ClientEvent",this.analyticsData=e},t=function(){var e=this;if(null===e.analyticsData.sessionId||0===e.analyticsData.sessionId.length)throw console.log("Error. The sessionId field cannot be null in the log entry"),"The sessionId field cannot be null in the log entry";if(null==e.analyticsData.connectionId||0==e.analyticsData.connectionId.length)throw console.log("Error. The connectionId field cannot be null in the log entry"),"The connectionId field cannot be null in the log entry";if(0==e.analyticsData.partnerId)throw console.log("Error. The partnerId field cannot be null in the log entry"),"The partnerId field cannot be null in the log entry";if(null==e.analyticsData.clientVersion||0==e.analyticsData.clientVersion.length)throw console.log("Error. The clientVersion field cannot be null in the log entry"),"The clientVersion field cannot be null in the log entry";if(null==e.analyticsData.source||0==e.analyticsData.source.length)throw console.log("Error. The source field cannot be null in the log entry"),"The source field cannot be null in the log entry";null!=e.analyticsData.logVersion&&0!=e.analyticsData.logVersion.length||(e.analyticsData.logVersion="2"),null!=e.analyticsData.guid&&0!=e.analyticsData.guid.length||(e.analyticsData.guid=n()),0==e.analyticsData.clientSystemTime&&(e.analyticsData.clientSystemTime=(new Date).getTime())},n=function(){for(var e=[],t="0123456789abcdef",n=0;36>n;n++)e[n]=t.substr(Math.floor(16*Math.random()),1);e[14]="4",e[19]=t.substr(3&e[19]|8,1),e[8]=e[13]=e[18]=e[23]="-";var a=e.join("");return a},a=function(){var e=this,t=e.analyticsData.payload||"";"object"==typeof t&&(t=JSON.stringify(t)),e.analyticsData.payload=t;var n=JSON.stringify(e.analyticsData),a=new XMLHttpRequest;a.open("POST",e.url,!0),a.setRequestHeader("Content-type","application/json"),a.send(n)};return e.prototype={constructor:OTKAnalytics,logEvent:function(e){this.analyticsData.action=e.action,this.analyticsData.variation=e.variation,t.call(this),a.call(this)}},e}(),TextChatAccPack=function(){var e,t,n,a,i,s,o,c=!1,l=!1,r="chat-container",d={clientVersion:"js-vsol-0.9",source:"text_chat_acc_pack",actionInitialize:"initialize",actionSendMessage:"send_message",actionReceiveMessage:"receive_message",actionMaximize:"maximize",actionMinimize:"minimize",actionSetMaxLength:"set_max_length",variationAttempt:"Attempt",variationError:"Failure",variationSuccess:"Success"},m=function(t){var a=!1;t.limitCharacterMessage&&(a=!0),t=t||{},imCharacterCount=t.charCountElement,e=t.acceleratorPack,n=t.sender,o=t.limitCharacterMessage||160,s=this;var i={sessionId:e.getSession().sessionId,connectionId:e.getSession().connection.connectionId,partnerId:e.getApiKey(),clientVersion:d.clientVersion,source:d.source};this._otkanalytics=new OTKAnalytics(i),a&&(s._addLogEvent(d.actionSetMaxLength,d.variationAttempt),s._addLogEvent(d.actionSetMaxLength,d.variationSuccess))},h=function(e){return uiLayout=['<div class="wms-widget-wrapper">','<div class="wms-widget-chat wms-widget-extras" id="chatContainer">','<div class="wms-messages-header hidden" id="chatHeader">',"<span>Chat with</span>","</div>",'<div id="wmsChatWrap">','<div class="wms-messages-holder" id="messagesHolder">','<div class="wms-message-item wms-message-sent">',"</div>","</div>",'<div class="wms-send-message-box">','<input type="text" maxlength='+o+' class="wms-message-input" placeholder="Enter your message here" id="messageBox">','<button class="wms-icon-check" id="sendMessage" type="submit"></button>','<div class="wms-character-count"><span><span id="character-count">0</span>/'+o+" characters</span></div>","</div>","</div>","</div>","</div>"].join("\n")},u=function(e){e=document.querySelector(e)||document.body;var t=document.createElement("section");t.innerHTML=h(),a=t.querySelector("#messageBox"),i=t.querySelector("#messagesHolder"),a.onkeyup=S.bind(this),a.onkeydown=T.bind(this),e.appendChild(t),document.getElementById("sendMessage").onclick=function(){v(a.value)},s._addLogEvent(d.actionInitialize,d.variationSuccess)},g=function(e){return t&&t.senderId===e.senderId&&moment(t.sentOn).fromNow()===moment(e.sentOn).fromNow()},v=function(e){_.isEmpty(e)||$.when(p(s._remoteParticipant,e)).then(function(t){f({senderId:n.id,alias:n.alias,message:e,sentOn:Date.now()}),this.futureMessageNotice&&(this.futureMessageNotice=!1)},function(e){s._handleMessageError(e)})},p=function(t,a){var i=new $.Deferred,o={text:a,sender:{id:n.id,alias:n.alias},sentOn:Date.now()};return s._addLogEvent(d.actionSendMessage,d.variationAttempt),console.log(e.getSession()),void 0===t?e.getSession().signal({type:"text-chat",data:o},function(e){if(e){if(e.message="Error sending a message. ",s._addLogEvent(d.actionSendMessage,d.variationFailure),413===e.code){var t=e.message+"The chat message is over size limit.";e.message=t}else if(500===e.code){var t=e.message+"Check your network connection.";e.message=t}i.reject(e)}else console.log("Message sent"),s._addLogEvent(d.actionSendMessage,d.variationSuccess),i.resolve(o)}):e.getSession().signal({type:"text-chat",data:o,to:t},function(e){e?(console.log("Error sending a message"),i.resolve(e)):(console.log("Message sent"),i.resolve(o))}),i.promise()},f=function(e){if(g(e)){$(".wms-item-text").last().append("<span>"+e.message+"</span>");var a=$(i);a[0].scrollTop=a[0].scrollHeight,E()}else x(n.id,n.alias,e.message,e.sentOn);t=e},y=function(e){s._addLogEvent(d.actionReceiveMessage,d.variationAttempt),"string"==typeof e.data&&(e.data=JSON.parse(e.data)),g(e.data)?$(".wms-item-text").last().append("<span>"+e.data.text+"</span>"):x(e.data.sender.id,e.data.sender.alias,e.data.text,e.data.sentOn),t=e.data,s._addLogEvent(d.actionReceiveMessage,d.variationSuccess)},w=function(e){if(console.log(e.code,e.message),500===e.code){var t=_.template($("#chatError").html());$(this.comms_elements.messagesView).append(t())}},x=function(e,t,a,s){var o=n.id===e?"wms-message-item wms-message-sent":"wms-message-item",c=M({username:t,message:a,messageClass:o,time:s}),l=$(i);l.append(c),E(),l[0].scrollTop=l[0].scrollHeight},M=function(e){var t=['<div class="'+e.messageClass+'" >','<div class="wms-user-name-initial"> '+e.username[0]+"</div>",'<div class="wms-item-timestamp"> '+e.username+', <span data-livestamp=" '+new Date(e.time)+'" </span></div>','<div class="wms-item-text">',"<span> "+e.message+"</span>","</div>","</div>"].join("\n");return t},D=function(t){var n=e.getSession().connection.connectionId,a=t.from.connectionId;if(a!==n){var i=y(t);i&&"function"==typeof i&&i(t)}},E=function(){a.value="",$(imCharacterCount).text("0")},T=function(e){var t=13===e.which||13===e.keyCode;!e.shiftKey&&t&&(e.preventDefault(),v.call(this,a.value))},S=function(){$(imCharacterCount).text(a.value.length)},C=function(e,t){var n=this,a={action:e,variation:t};n._otkanalytics.logEvent(a)};return m.prototype={constructor:m,onMaximaze:function(){},onMinimize:function(){},onError:function(){},initTextChat:function(t){C.call(this,d.actionInitialize,d.variationAttempt),c=!0,l=!0,u.call(this,t),e.getSession().on("signal:text-chat",this._handleTextChat.bind(this))},showTextChat:function(){C.call(this,d.actionMaximize,d.variationAttempt),document.getElementById(r).classList.remove("hidden"),this.setDisplayTextChat(!0),C.call(this,d.actionMaximize,d.variationSuccess),this.onMaximaze()},hideTextChat:function(){C.call(this,d.actionMinimize,d.variationAttempt),document.getElementById(r).classList.add("hidden"),this.setDisplayTextChat(!1),C.call(this,d.actionMinimize,d.variationSuccess),this.onMinimize()},getEnableTextChat:function(){return c},getDisplayTextChat:function(){return l},setDisplayTextChat:function(e){l=e},_handleTextChat:function(e){D.call(this,e)},_handleMessageError:function(e){w.call(this,e),this.onError()},_addLogEvent:function(e,t){C.call(this,e,t)}},m}();
var TextChatAccPack = (function () {
  var enableTextChat = false;
  var displayTextChat = false;
  var acceleratorPack;
  var textChatDiv = 'chat-container';
  var lastMessage, sender, composer;
  var newMessages, self, limitCharacterMessage;

  var logEventData = {
  //vars for the analytics logs. Internal use
    clientVersion: 'js-vsol-0.9',
    source: 'text_chat_acc_pack',
    actionInitialize: 'initialize', 
    actionSendMessage: 'send_message',
    actionReceiveMessage: 'receive_message',
    actionMaximize: 'maximize',
    actionMinimize: 'minimize',
    actionSetMaxLength: 'set_max_length',
    variationAttempt: 'Attempt',
    variationError: 'Failure',
    variationSuccess: 'Success'
  };

  // Constructor
  var TextChatAccPack = function (options) {
    var setMaxLengthMessage = false;
    if (options.limitCharacterMessage) {
      setMaxLengthMessage = true;
    }

    options = options || {};
    imCharacterCount = options.charCountElement;
    acceleratorPack = options.acceleratorPack;
    sender = options.sender;
    limitCharacterMessage = options.limitCharacterMessage || 160;
    self = this;

    var _otkanalyticsData = {
      sessionId: acceleratorPack.getSession().sessionId,
      connectionId: acceleratorPack.getSession().connection.connectionId,
      partnerId: acceleratorPack.getApiKey(),
      clientVersion: logEventData.clientVersion,
      source: logEventData.source
    };

    //init the analytics logs
    this._otkanalytics = new OTKAnalytics(_otkanalyticsData);

    if (setMaxLengthMessage) {
      self._addLogEvent(logEventData.actionSetMaxLength, logEventData.variationAttempt);
      self._addLogEvent(logEventData.actionSetMaxLength, logEventData.variationSuccess);
    }
  };

  // Private methods
  var renderUILayout = function (type) {

    return uiLayout = [
      '<div class="wms-widget-wrapper">',
      '<div class="wms-widget-chat wms-widget-extras" id="chatContainer">',
      '<div class="wms-messages-header hidden" id="chatHeader">',
      '<span>Chat with</span>',
      '</div>',
      '<div id="wmsChatWrap">',
      '<div class="wms-messages-holder" id="messagesHolder">',
      '<div class="wms-message-item wms-message-sent">',
      '</div>',
      '</div>',
      '<div class="wms-send-message-box">',
      '<input type="text" maxlength='+limitCharacterMessage+' class="wms-message-input" placeholder="Enter your message here" id="messageBox">',
      '<button class="wms-icon-check" id="sendMessage" type="submit"></button>',
      '<div class="wms-character-count"><span><span id="character-count">0</span>/'+limitCharacterMessage+' characters</span></div>',
      '</div>',
      '</div>',
      '</div>',
      '</div>'
    ].join('\n');
  };

  var _setupUI = function (parent) {
    parent = document.querySelector(parent) || document.body;
    var chatView = document.createElement('section');
    chatView.innerHTML = renderUILayout();
    composer = chatView.querySelector('#messageBox');
    newMessages = chatView.querySelector('#messagesHolder');
    composer.onkeyup = _updateCharCounter.bind(this);
    composer.onkeydown = _controlComposerInput.bind(this);
    parent.appendChild(chatView);
    document.getElementById('sendMessage').onclick = function(){
      _sendTxtMessage(composer.value);
    };
    //add INITIALIZE success log event 
    self._addLogEvent(logEventData.actionInitialize, logEventData.variationSuccess);
  };

  var _shouldAppendMessage = function (data) {
    return lastMessage && lastMessage.senderId === data.senderId && moment(lastMessage.sentOn).fromNow() === moment(data.sentOn).fromNow();
  };

  var _sendTxtMessage = function (text) {
    if (!_.isEmpty(text)) {
      $.when(_sendMessage(self._remoteParticipant, text))
        .then(function (data) {
          _handleMessageSent({senderId: sender.id, alias: sender.alias, message: text, sentOn: Date.now()});
          if (this.futureMessageNotice)
            this.futureMessageNotice = false;
        }, function (error) {
          self._handleMessageError(error);
        });
    }
  };

  var _sendMessage = function (recipient, message) {
    var deferred = new $.Deferred();
    var messageData = {
      text: message,
      sender: {
        id: sender.id,
        alias: sender.alias,
      },
      sentOn: Date.now()
    };

    //add SEND_MESSAGE attempt log event 
    self._addLogEvent(logEventData.actionSendMessage, logEventData.variationAttempt);
  
    console.log(acceleratorPack.getSession());
    if (recipient === undefined) {
      acceleratorPack.getSession().signal({
          type: 'text-chat',
          data: messageData,
        },
        function (error) {
          if (error) {
            error.message = "Error sending a message. ";
            //add SEND_MESSAGE attempt log event 
            self._addLogEvent(logEventData.actionSendMessage, logEventData.variationFailure);
            if (error.code === 413) {
              var errorStr = error.message + "The chat message is over size limit."
              error.message = errorStr;
            }
            else {
              if (error.code === 500) {
                var errorStr = error.message + "Check your network connection."
                error.message = errorStr;
              }
            }
            deferred.reject(error);
          } else {
            console.log('Message sent');
            //add SEND_MESSAGE attempt log event 
            self._addLogEvent(logEventData.actionSendMessage, logEventData.variationSuccess);   
            deferred.resolve(messageData);
          }
        }
      );
    }
    else {
      acceleratorPack.getSession().signal({
          type: 'text-chat',
          data: messageData,
          to: recipient
        }, function (error) {
          if (error) {
            console.log('Error sending a message');
            deferred.resolve(error);
          } else {
            console.log('Message sent');
            deferred.resolve(messageData);
          }
        }
      );
    }

    return deferred.promise();
  };
  var _handleMessageSent = function (data) {
    if (_shouldAppendMessage(data)) {
      $('.wms-item-text').last().append('<span>' + data.message + '</span>');
      var chatholder = $(newMessages);
      chatholder[0].scrollTop = chatholder[0].scrollHeight;
      _cleanComposer();

    } else {
      _renderChatMessage(sender.id, sender.alias, data.message, data.sentOn);
    }
    lastMessage = data;
  };
  var _onIncomingMessage = function (signal) {
    self._addLogEvent(logEventData.actionReceiveMessage, logEventData.variationAttempt);
    if(typeof signal.data === 'string' ){
      signal.data = JSON.parse(signal.data);
    }
    if (_shouldAppendMessage(signal.data)) {
      $(".wms-item-text").last().append('<span>' + signal.data.text + '</span>');
    } else {
      _renderChatMessage(signal.data.sender.id, signal.data.sender.alias, signal.data.text, signal.data.sentOn);
    }
    lastMessage = signal.data;
     self._addLogEvent(logEventData.actionReceiveMessage, logEventData.variationSuccess);
  };
  var _handleMessageError = function (error) {
    console.log(error.code, error.message);
    if (error.code === 500) {
      var view = _.template($('#chatError').html());
      $(this.comms_elements.messagesView).append(view());
    }
  };
  var _renderChatMessage = function (messageSenderId, messageSenderAlias, message, sentOn) {
    var sentByClass = sender.id === messageSenderId ? 'wms-message-item wms-message-sent' : 'wms-message-item';

    var view = _getBubbleHtml({
      username: messageSenderAlias,
      message: message,
      messageClass: sentByClass,
      time: sentOn
    });
    var chatholder = $(newMessages);
    chatholder.append(view);
    _cleanComposer();
    chatholder[0].scrollTop = chatholder[0].scrollHeight;
  };

  var _getBubbleHtml = function(message){
    var bubble =
      [
        '<div class="'+ message.messageClass +'" >',
        '<div class="wms-user-name-initial"> '+message.username[0] +'</div>',
        '<div class="wms-item-timestamp"> '+message.username+', <span data-livestamp=" '+new Date(message.time)+'" </span></div>',
        '<div class="wms-item-text">',
        '<span> '+message.message +'</span>',
        '</div>',
        '</div>'].join('\n');
    return bubble;
  };

  var _handleTextChat = function (event) {
    var me = acceleratorPack.getSession().connection.connectionId;
    var from = event.from.connectionId;
    if (from !== me) {
      var handler = _onIncomingMessage(event);
      if (handler && typeof handler === 'function') {
        handler(event);
      }
    }
  };

  var _cleanComposer = function(){
    composer.value = '';
    $(imCharacterCount).text("0");
  };

  var _controlComposerInput = function (evt) {
    var isEnter = evt.which === 13 || evt.keyCode === 13;
    if (!evt.shiftKey && isEnter) {
      evt.preventDefault();
      _sendTxtMessage.call(this, composer.value);
    }
  };
  var _updateCharCounter = function () {
    $(imCharacterCount).text(composer.value.length);
  };
  
  var _log = function (action, variation) {
    var self = this;
    var data = {
        action: action,
        variation: variation
    };
    self._otkanalytics.logEvent(data);
  };
  //    **************************************************************************************************************
  TextChatAccPack.prototype = {
    constructor: TextChatAccPack,

    initTextChat: function(parent_holder){
      //add INITIALIZE attempt log event 
      _log.call(this, logEventData.actionInitialize, logEventData.variationAttempt);
  
      enableTextChat = true;
      displayTextChat = true;
      _setupUI.call(this,parent_holder);
      acceleratorPack.getSession().on('signal:text-chat', this._handleTextChat.bind(this));
    },

    showTextChat: function(){
      //add MAXIMIZE attempt log event 
      _log.call(this, logEventData.actionMaximize, logEventData.variationAttempt);
  
      document.getElementById(textChatDiv).classList.remove('hidden');
      this.setDisplayTextChat(true);

      //add MAXIMIZE success log event 
      _log.call(this, logEventData.actionMaximize, logEventData.variationSuccess);
  
    },

    hideTextChat: function() {
      //add MINIMIZE attempt log event 
      _log.call(this, logEventData.actionMinimize, logEventData.variationAttempt);
  
      document.getElementById(textChatDiv).classList.add('hidden');
      this.setDisplayTextChat(false);

      //add MINIMIZE success log event 
      _log.call(this, logEventData.actionMinimize, logEventData.variationSuccess);
  
    },

    getEnableTextChat: function(){
      return enableTextChat;
    },
    getDisplayTextChat: function(){
      return displayTextChat;
    },
    setDisplayTextChat: function(value){
      displayTextChat = value;
    },

    _handleTextChat: function (data) {
      _handleTextChat.call(this, data);
    },
    _handleMessageError: function (data) {
      _handleMessageError.call(this, data);
    },
    _addLogEvent: function(action, variation) {
      _log.call(this, action, variation);
    }
  };
  return TextChatAccPack;
})();

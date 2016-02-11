package com.opentok.android.textchat;


import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MessagesAdapter extends RecyclerView.Adapter<MessagesAdapter.MessageViewHolder>{

    private List<ChatMessage> messagesList = new ArrayList<ChatMessage>();
    private View messageView;

    public MessagesAdapter(List<ChatMessage> messagesList) {
        this.messagesList = messagesList;
    }

    @Override
    public MessageViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View view = LayoutInflater.from(parent.getContext()).inflate(viewType, parent, false);
        return new MessageViewHolder(view);

    }

    @Override
    public void onBindViewHolder(MessageViewHolder holder, int position) {

        ChatMessage message = messagesList.get(position);
        SimpleDateFormat ft =
                new SimpleDateFormat("hh:mm a");
        holder.msgInfo.setText(message.getSenderAlias() + ", " + ft.format(new Date(message.getTimestamp())).toString());
        holder.initial.setText(String.valueOf(Character.toUpperCase((message.getSenderAlias().charAt(0)))));
        holder.messageText.setText(message.getText());

    }

    @Override
    public int getItemCount() {
        return (null != messagesList ? messagesList.size() : 0);
    }

    @Override
    public int getItemViewType(int position) {

        ChatMessage item = messagesList.get(position);

        if(item.getMessageStatus() == ChatMessage.MessageStatus.SENT_MESSAGE)
            return R.layout.sent_row;
        else
            return R.layout.received_row;
    }

    class MessageViewHolder extends RecyclerView.ViewHolder {

        public TextView msgInfo, messageText, initial;

        public MessageViewHolder(View view) {
            super(view);
            this.msgInfo = (TextView) view.findViewById(R.id.msg_info);
            this.messageText = (TextView) view.findViewById(R.id.msg_text);
            this.initial = (TextView) view.findViewById(R.id.initial);
        }
    }

}
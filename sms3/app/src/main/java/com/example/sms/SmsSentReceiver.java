package com.example.sms;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

public class SmsSentReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (getResultCode() == Activity.RESULT_OK) {
            Toast.makeText(context, "SMS sent", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(context, "Failed to send SMS", Toast.LENGTH_SHORT).show();
        }
    }
}

package com.example.sms;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

public class SmsDeliveredReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (getResultCode() == Activity.RESULT_OK) {
            Toast.makeText(context, "SMS delivered", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(context, "SMS not delivered", Toast.LENGTH_SHORT).show();
        }
    }
}

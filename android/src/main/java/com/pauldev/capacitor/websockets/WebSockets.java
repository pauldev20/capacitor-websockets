package com.pauldev.capacitor.websockets;

import android.util.Log;

public class WebSockets {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }
}

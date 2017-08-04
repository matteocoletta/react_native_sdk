package com.adjust.examples;

import com.adjust.testlibrary.TestLibrary;

import android.util.Log;

import com.facebook.react.bridge.*;
import com.facebook.react.modules.core.*;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

public class AdjustTest extends ReactContextBaseJavaModule {
    private static final String TAG = "AdjustTest";

    private TestLibrary testLibrary;
    private String selectedTests;

    public AdjustTest(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "AdjustTest";
    }

    @ReactMethod
    public void initTestSession(String baseUrl) {
        Log.d(TAG, "initTestSession() with baseUrl[" + baseUrl + "]");

        testLibrary = new TestLibrary(baseUrl, new CommandListener(getReactApplicationContext()));
        if(this.selectedTests != null 
                && !this.selectedTests.isEmpty()) {
            testLibrary.setTests(this.selectedTests);
                }
        testLibrary.initTestSession("react_native4.11.4@android4.11.4");
    }

    @ReactMethod
    public void setTests(String setTests) {
        this.selectedTests = setTests;
    }

    @ReactMethod
    public void addInfoToSend(String key, String value) {
        if (null != testLibrary) {
            testLibrary.addInfoToSend(key, value);
        }
    }

    @ReactMethod
    public void sendInfoToServer() {
        if (null != testLibrary) {
            testLibrary.sendInfoToServer();
        }
    }
}

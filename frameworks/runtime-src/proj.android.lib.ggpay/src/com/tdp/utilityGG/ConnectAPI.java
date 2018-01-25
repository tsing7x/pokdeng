package com.tdp.utilityGG;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Build;
import android.util.Log;

import com.tdp.callbackGG.OnConnectAPIListener;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;

public class ConnectAPI {

    private final String TAG = "<-- ConnectAPI -->";
    private final int CONNECT_TIMEOUT = 15 * 1000;
    private final int READ_TIMEOUT = 20 * 1000;
    byte[] jostDatab;
    Context context = null;
    private int requestCode;
    private String apiURL;
    private String jostData = null;
    private String errMsg = null;
    private ProgressDialog pDialog;
    private OnConnectAPIListener onConnectAPIListener;

    public ConnectAPI(String apiURL, String jsonData, int requestCode, OnConnectAPIListener onConnectAPIListener, Context context) {
        this.apiURL = apiURL;
        this.requestCode = requestCode;
        this.jostData = jsonData;
        this.onConnectAPIListener = onConnectAPIListener;
        this.context = context;
    }

    @SuppressLint("NewApi")
    public void startExecute() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
            new GetDataFormAPI().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, apiURL);
        else
            new GetDataFormAPI().execute(apiURL);
    }

    private String connectHttpGet(String strUrl) throws IOException {

        String content = null;

        URL url = new URL(strUrl);
        try {
            HttpURLConnection httpCon = (HttpURLConnection) url.openConnection();
            httpCon.setRequestMethod("GET");
            httpCon.setConnectTimeout(CONNECT_TIMEOUT);
            httpCon.setReadTimeout(READ_TIMEOUT);
            httpCon.connect();

            int response = httpCon.getResponseCode();

            if (response == HttpURLConnection.HTTP_OK) {
                content = getContent(httpCon.getInputStream(), httpCon.getContentLength());
            } else {
                errMsg = "Error Code : " + response;
            }
        } catch (Exception e) {
            errMsg = e.toString();
            Log.d(TAG, errMsg);
        }

        return content;
    }

    private String connectHttpPost(String strUrl, String jsonData) throws IOException {

        Log.d(TAG, "Json Post Data : " + jsonData);


        URL url = new URL(strUrl);
        try {
            HttpURLConnection httpCon = (HttpURLConnection) url.openConnection();
            httpCon.setRequestProperty("Accept", "application/json");
            httpCon.setRequestProperty("Content-type", "application/json");
            httpCon.setRequestMethod("POST");
            httpCon.setConnectTimeout(CONNECT_TIMEOUT);
            httpCon.setDoInput(true);
            httpCon.setDoOutput(true);
            httpCon.setUseCaches(false);

            DataOutputStream dos = new DataOutputStream(httpCon.getOutputStream());
            dos.writeBytes(jsonData);
            dos.flush();
            dos.close();
            InputStream ins = httpCon.getInputStream();
            BufferedReader rd = new BufferedReader(new InputStreamReader(ins, "UTF-8"));

            String line;
            StringBuffer response = new StringBuffer();
            while ((line = rd.readLine()) != null) {
                response.append(line);
            }

            rd.close();

            Log.d(TAG, "Json Result Data : " + response.toString());

            return response.toString();
        } catch (Exception e) {
            errMsg = e.toString();
            Log.d(TAG, errMsg);
        }

        return null;
    }

    void dialog() {
        pDialog = new ProgressDialog(context);
        pDialog.setMessage("Setup Billing ...");
        pDialog.setIndeterminate(false);
        pDialog.setCancelable(false);
        pDialog.show();
    }

    private String getContent(InputStream stream, int len) throws IOException, UnsupportedEncodingException {

        Reader reader = null;
        reader = new InputStreamReader(stream, "UTF-8");
        char[] buffer = new char[len];
        reader.read(buffer);
        return new String(buffer);
    }

    private class GetDataFormAPI extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String... url) {
            //dialog();
            String response = null;
            try {
                if (jostData == null)
                    response = connectHttpGet(url[0]);
                else
                    response = connectHttpPost(url[0], jostData);

                return response;
            } catch (Exception e) {
                errMsg = e.toString();
                return null;
            }

        }

        @Override
        protected void onPostExecute(String response) {
            if (response != null)

                onConnectAPIListener.onSuccess(requestCode, response);

            else

                onConnectAPIListener.onFail(requestCode, errMsg);
            //pDialog.dismiss();
        }
    }

}

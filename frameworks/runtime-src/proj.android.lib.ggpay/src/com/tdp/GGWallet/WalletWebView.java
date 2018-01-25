package com.tdp.GGWallet;


import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.http.SslError;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.webkit.SslErrorHandler;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;


import com.tdp.apiGG.ApiPayment;

public class WalletWebView extends Activity implements OnClickListener {

    // View
    WebView wallet_webview;
    String AppID, AppSecret, TranID, referenceID, encryptMsg;
    String deviceID, itemname;
    Button btCloseMobilewebView;
    //String gameCode,currency ;
    String item_name, app_user_id, reference_id, other;
    double charge_amt;
    ApiPayment getresult = new ApiPayment(this);
    TextView show;
    //int price ;
    String TAG = "<--WalletWebView-->";
    ApiPayment tdpAuthen = null;
    String ss = null;
    static final boolean DISABLE_SSL_CHECK_FOR_TESTING = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
        setContentView(com.tdp.goodgamespayment.framework.R.layout.wallet_webview);

        tdpAuthen = new ApiPayment(this);

        charge_amt = getIntent().getDoubleExtra("charge_amt", charge_amt);
        item_name = getIntent().getStringExtra("item_name");
        app_user_id = getIntent().getStringExtra("app_user_id");
        reference_id = getIntent().getStringExtra("reference_id");
        other = getIntent().getStringExtra("other");
        //ss = getIntent().getStringExtra("Check");
        //app_user_id= getIntent().getStringExtra("app_user_id");
        widget();
        listener();
        //chkStatus();

        tdpAuthen.setParameterWallet(item_name, charge_amt, app_user_id, reference_id, wallet_webview, other);
        btCloseMobilewebView.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                // transactionID = TDPGlobal.transactionID ;

                closeWebView();
            }
        });

    }

    private void listener() {
        btCloseMobilewebView.setOnClickListener(this);
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void widget() {
        wallet_webview = (WebView) findViewById(com.tdp.goodgamespayment.framework.R.id.wallet_WebView);
        wallet_webview.getSettings().setJavaScriptEnabled(true);
        wallet_webview.getSettings().setLoadsImagesAutomatically(true);

        wallet_webview.getSettings().setBuiltInZoomControls(true);

        wallet_webview.requestFocusFromTouch();

        wallet_webview.setWebViewClient(new WebViewClient());
        wallet_webview.setWebChromeClient(new WebChromeClient());
        //webAuthenCenter.getSettings().setDomStorageEnabled(true);
        //webAuthenCenter.getSettings().setLoadsImagesAutomatically(true);
        wallet_webview.clearCache(false);
        //webAuthenCenter.setWebChromeClient(new WebChromeClient());

        wallet_webview.setWebViewClient(new WebClient());
        btCloseMobilewebView = (Button) findViewById(com.tdp.goodgamespayment.framework.R.id.btCloseWalletwebView);
        //	show = (TextView) findViewById(com.tdp.tdpsdk.R.id.showURL);
        //Log.d("zzzzzzxxxxxxxxx", "mmmmmmmmmmmmmmmmm,");
    }


    public void closeWebView() {
        tdpAuthen.getresult_GGWallet();
        finish();
    }

    @SuppressLint("ShowToast")
    @Override
    public void onBackPressed() {

        closeWebView();

        super.onBackPressed();
    }

    private void chkStatus() {
        ConnectivityManager cn = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo nf = cn.getActiveNetworkInfo();
        if (nf != null && nf.isConnected() == true) {
            Toast.makeText(this, "Network Available", Toast.LENGTH_LONG).show();

        } else {
            Toast.makeText(this, "Network Not Available", Toast.LENGTH_LONG).show();

        }
    }

    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub

    }

    private class WebClient extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            //Log.d("Webview1", url);
            //show.setText(url);
            //view.loadUrl(url);
            return super.shouldOverrideUrlLoading(view, url);
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            super.onPageStarted(view, url, favicon);
            //Log.d("Webview2", url);
            //show.setText(url);
            setProgressBarIndeterminateVisibility(true);

        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            //Log.d("Webview3", url);
            setProgressBarIndeterminateVisibility(false);
        }

        @Override
        public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
        	 if (DISABLE_SSL_CHECK_FOR_TESTING) {
                 handler.proceed();
             } else {
                 super.onReceivedSslError(view, handler, error);

                 handler.cancel();
                 
             }
        	
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
            super.onReceivedError(view, errorCode, description, failingUrl);
            Toast.makeText(getApplicationContext(), "Your Internet Connection May not be active Or " + description, Toast.LENGTH_LONG).show();
        }
    }
}

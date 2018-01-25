package com.tdp.session;

import android.content.Context;

import com.tdp.utilityGG.Utility;
import com.tdp.variableGG.TDPGlobal;

public class GGPaymentSession {

    public GGPaymentSession(String APP_ID, String APP_SECRET_KEY) {

        TDPGlobal.APP_ID = APP_ID;
        TDPGlobal.SECRET_KEY = APP_SECRET_KEY;
    }

    public GGPaymentSession(Context context, String APP_ID, String APP_SECRET_KEY) {
        Utility.savePreferences(context, "APP_ID", APP_ID);
        Utility.savePreferences(context, "APP_SECRET_KEY", APP_SECRET_KEY);
        TDPGlobal.APP_ID = Utility.loadSavedPreferences(context, "APP_ID");
        TDPGlobal.SECRET_KEY = Utility.loadSavedPreferences(context, "APP_SECRET_KEY");
    }
}

package com.tdp.utilityGG;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.preference.PreferenceManager;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import android.widget.Toast;

import java.io.InputStream;
import java.io.OutputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Utility {

    private static SharedPreferences sharedPreferences;


    public static boolean wifiManage(Context context) {
        boolean check = false;
        ConnectivityManager connManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo mWifi = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);

        if (mWifi.isConnected()) {
            // Do whatever
            check = true;
        }
        return check;

		/*ConnectivityManager cn=(ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);
	    NetworkInfo nf=cn.getActiveNetworkInfo();
	    if(nf != null && nf.isConnected()==true )
	    {
	       
	    	check = true ;
	    }
		return check;*/
    }


    public static boolean checkInternet(Context context) {
        boolean check = false;


        ConnectivityManager cn = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo nf = cn.getActiveNetworkInfo();
        if (nf != null && nf.isConnected() == true) {

            check = true;
        }
        return check;
    }

    public static String md5(String str) {
        MessageDigest digest;
        try {
            digest = MessageDigest.getInstance("MD5");
            digest.reset();
            digest.update(str.getBytes());
            byte[] a = digest.digest();
            int len = a.length;
            StringBuilder sb = new StringBuilder(len << 1);
            for (int i = 0; i < len; i++) {
                sb.append(Character.forDigit((a[i] & 0xf0) >> 4, 16));
                sb.append(Character.forDigit(a[i] & 0x0f, 16));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String getOperaTerName(Context context) {
        TelephonyManager telephonyManager = ((TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE));
        String opeName = telephonyManager.getNetworkOperatorName();
        return opeName;
    }

    public static String getDeviceID(Context context) {
        return Secure.getString(context.getContentResolver(), Secure.ANDROID_ID);
    }

    public static void ShowMsg(Context mContext, String msg) {
        Toast.makeText(mContext, msg, Toast.LENGTH_SHORT).show();
    }

    public static void savePreferences(Context mContext, String key, String value) {
        sharedPreferences = PreferenceManager.getDefaultSharedPreferences(mContext);
        Editor editor = sharedPreferences.edit();
        editor.putString(key, value);
        editor.commit();
    }

    public static String loadSavedPreferences(Context mContext, String key) {
        sharedPreferences = PreferenceManager.getDefaultSharedPreferences(mContext);
        String str = sharedPreferences.getString(key, "");
        return str;
    }

    public static void CopyStream(InputStream is, OutputStream os) {
        final int buffer_size = 1024;
        try {
            byte[] bytes = new byte[buffer_size];
            for (; ; ) {
                int count = is.read(bytes, 0, buffer_size);
                if (count == -1)
                    break;
                os.write(bytes, 0, count);
            }
        } catch (Exception ex) {
        }
    }

    public static String getreferenceID(Context context) {
        String device = Utility.getDeviceID(context);

        String digi = difi();
        String referentID = device + digi;
        //Log.d("asasasdededed", referentID);
        //Log.d("digi", digi);
        return referentID;

    }

    private static String difi() {
        Random r = new Random();
        List<Integer> codes = new ArrayList<Integer>();
        for (int i = 0; i < 10; i++) {
            int x = r.nextInt(9999);
            while (codes.contains(x))
                x = r.nextInt(9999);
            codes.add(x);
        }
        String str = String.format("%04d", codes.get(0));

        return str;
    }

    private void savePreferences(String key, String value, Context mContext) {
        sharedPreferences = PreferenceManager.getDefaultSharedPreferences(mContext);
        Editor editor = sharedPreferences.edit();
        editor.putString(key, value);
        editor.commit();
    }

    private String loadSavedPreferences(String key, Context mContext) {
        sharedPreferences = PreferenceManager.getDefaultSharedPreferences(mContext);
        String str = sharedPreferences.getString(key, "");
        return str;
    }
}

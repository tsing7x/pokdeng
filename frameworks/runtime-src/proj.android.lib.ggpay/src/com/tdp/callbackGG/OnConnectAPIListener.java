package com.tdp.callbackGG;

public interface OnConnectAPIListener {

    public void onSuccess(int requestCode, String response);

    public void onFail(int requestCode, String msgError);
}

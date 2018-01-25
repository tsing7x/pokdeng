package com.tdp.callbackGG;

public interface CallbackPayMentListener {

    public void onSuccess(String result);

    public void onFail(String msgError);
}

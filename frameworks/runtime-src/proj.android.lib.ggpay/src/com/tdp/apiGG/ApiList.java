package com.tdp.apiGG;


public class ApiList {


    // ----------------------------------------   API Standard -------------------------------------------------------------------//
    // API Get Unix Time
    public static final String apiGetUnixTime = "http://api.gg.in.th/WCF_Platform_Tool/WCF_Platform_Tool.svc/getUNIXTimeNow";


    //-------------------------------------------------Payment ------------------------------------------------------------------------------------//

    public static String apiPaymentTransID = "http://payment.gg.in.th/payment_gateway/paymentservice/RequestPaymentTransID.ashx" +
            "?app_id=%s" +
            "&item_name=%s" +
            "&price=%s" +
            "&currency=%s" +
            "&payment_code=%s" +
            "&device_id=%s" +
            "&app_user_id=%s" +
            "&reference_id=%s" +
            "&timestamp=%s" +
            "&other=%s" +
            "&hash_value=%s";

    public static String apiPayment_Information = "http://payment.gg.in.th/payment_gateway/paymentservice/RequestPayment.aspx ";

    public static String apiclose_Payment_Information = "http://payment.gg.in.th/payment_gateway/paymentservice/RequestPaymentResult.ashx" +
            "?app_id=%s" +
            "&transaction_id=%s" +
            "&timestamp=%s" +
            "&hash_value=%s";

    public static String apiPaymentTransIDdev = "http://devpayment.gg.in.th/payment_gateway/paymentservice/RequestPaymentTransID.ashx" +
            "?app_id=%s" +
            "&item_name=%s" +
            "&price=%s" +
            "&currency=%s" +
            "&payment_code=%s" +
            "&device_id=%s" +
            "&app_user_id=%s" +
            "&reference_id=%s" +
            "&timestamp=%s" +
            "&other=%s" +
            "&hash_value=%s";

    public static String apiPayment_Informationdev = "http://devpayment.gg.in.th/payment_gateway/paymentservice/RequestPayment.aspx ";

    public static String apiclose_Payment_Informationdev = "http://devpayment.gg.in.th/payment_gateway/paymentservice/RequestPaymentResult.ashx" +
            "?app_id=%s" +
            "&transaction_id=%s" +
            "&timestamp=%s" +
            "&hash_value=%s";


    //------------------------------------------------------ api Coin --------------------------------------------------------------------//
    public static String apiGGCoinRequestTransID = "http://payment.gg.in.th/payment_gateway/GGCoinPayment/RequestTransID.ashx?" +
            "app_id=%s" +
            "&item_name=%s" +
            "&charge_amt=%s" +
            "&device_id=%s" +
            "&app_user_id=%s" +
            "&reference_id=%s" +
            "&timestamp=%s" +
            "&other=%s&" +
            "hash_value=%s";

    public static String apiRequestGGCoin = "http://payment.gg.in.th/payment_gateway/GGCoinPayment/RequestGGCoinPayment.aspx";

    public static String apiRequestResultGGCoin = "http://payment.gg.in.th/payment_gateway/ggcoinpayment/requestresult.ashx?"
            + "app_id=%s" +
            "&transaction_id=%s" +
            "&timestamp=%s" +
            "&hash_value=%s";

}

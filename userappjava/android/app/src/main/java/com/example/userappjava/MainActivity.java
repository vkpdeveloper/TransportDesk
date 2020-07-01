package com.example.userappjava;

// import android.app.ProgressDialog;
// import android.os.AsyncTask;
// import android.os.Bundle;
// import android.util.Log;

// import androidx.annotation.NonNull;

// import com.paytm.pgsdk.PaytmOrder;
// import com.paytm.pgsdk.PaytmPGService;
// import com.paytm.pgsdk.PaytmPaymentTransactionCallback;

// import org.json.JSONException;
// import org.json.JSONObject;

// import java.util.ArrayList;
// import java.util.HashMap;
// import java.util.Map;
// import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
//implements PaytmPaymentTransactionCallback {

//     private static final String CHANNEL = "com.vkpdeveloper.paytmpayments/paytm";
//     MethodChannel.Result result;

//     public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//         GeneratedPluginRegistrant.registerWith(flutterEngine);
//         new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//                 .setMethodCallHandler(
//                         (call, result) -> {
//                             this.result = result;
//                             String orderId = call.argument("orderId");
//                             String customerId = call.argument("customerId");
//                             String amount = call.argument("amount");
//                             switch (call.method){
//                                 case "payWithPaytm":
//                                     sendUserDetailTOServerdd dl = new sendUserDetailTOServerdd(orderId, customerId, amount);
//                                     dl.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
//                                     break;
//                             }
//                         }
//                 );
//     }

//     void sendResponse(Map<String, Object> parmas) {
//         result.success(parmas);
//     }

//     @Override
//     public void onTransactionResponse(Bundle inResponse) {
//         Map<String, Object> parmsMap = new HashMap<>();
//         for (String key : inResponse.keySet()) {
//             parmsMap.put(key, Objects.requireNonNull(inResponse.getString(key)));
//         }

//         sendResponse(parmsMap);
//     }

//     @Override
//     public void networkNotAvailable() {
//         Map<String, Object> parmsMap = new HashMap<>();
//         parmsMap.put("error", true);
//         parmsMap.put("result", "internetPorblem");
//         sendResponse(parmsMap);
//     }

//     @Override
//     public void clientAuthenticationFailed(String inErrorMessage) {
//         Map<String, Object> parmsMap = new HashMap<>();
//         parmsMap.put("error", true);
//         parmsMap.put("result", "client auth fail");
//         sendResponse(parmsMap);
//     }

//     @Override
//     public void someUIErrorOccurred(String inErrorMessage) {
//         Map<String, Object> parmsMap = new HashMap<>();
//         parmsMap.put("error", true);
//         parmsMap.put("result", "ui error occured");
//         sendResponse(parmsMap);
//     }

//     @Override
//     public void onErrorLoadingWebPage(int iniErrorCode, String inErrorMessage, String inFailingUrl) {
//         Map<String, Object> parmsMap = new HashMap<>();
//         parmsMap.put("error", true);
//         parmsMap.put("result", inErrorMessage);
//         sendResponse(parmsMap);
//     }

//     @Override
//     public void onBackPressedCancelTransaction() {
//         Map<String, Object> parmsMap = new HashMap<>();
//         parmsMap.put("error", true);
//         parmsMap.put("result", "back pressed");
//         sendResponse(parmsMap);
//     }

//     @Override
//     public void onTransactionCancel(String inErrorMessage, Bundle inResponse) {
//         Map<String, Object> parmsMap = new HashMap<>();
//         for (String key : inResponse.keySet()) {
//             parmsMap.put(key, Objects.requireNonNull(inResponse.getString(key)));
//         }

//         sendResponse(parmsMap);
//     }
// }

//     public class sendUserDetailTOServerdd extends AsyncTask<ArrayList<String>, Void, String> {

//         private String orderId;
//         private String customerId;
//         private String amount;
//         String mid = "your mid";
//         String verifyUrl = "https://pguat.paytm.com/paytmchecksum/paytmCallback.jsp";
//         String url = "Your checksum url";

//         sendUserDetailTOServerdd(String orderId, String customerId, String amount) {
//             this.orderId = orderId;
//             this.customerId = customerId;
//             this.amount = amount;
//         }

//         private ProgressDialog dialog = new ProgressDialog(MainActivity.this);
//         String CHECKSUMHASH = "";

//         @Override
//         protected void onPreExecute() {
//             this.dialog.setMessage("Please wait");
//             this.dialog.show();
//         }

//         protected String doInBackground(ArrayList<String>... alldata) {
//             JsonParser jsonParser = new JsonParser(MainActivity.this);
//             String param =
//                     "MID=" + mid +
//                             "&ORDER_ID=" + orderId +
//                             "&CUST_ID=" + customerId +
//                             "&CHANNEL_ID=WAP&TXN_AMOUNT=" + amount + "&WEBSITE=DEFAULT" +
//                             "&CALLBACK_URL=" + verifyUrl + "&INDUSTRY_TYPE_ID=Retail";

//             JSONObject jsonObject = jsonParser.makeHttpRequest(url, "POST", param);
//             if (jsonObject != null) {
//                 try {

//                     CHECKSUMHASH = jsonObject.has("CHECKSUMHASH") ? jsonObject.getString("CHECKSUMHASH") : "";

//                 } catch (JSONException e) {
//                     e.printStackTrace();
//                 }
//             }
//             return CHECKSUMHASH;
//         }

//         @Override
//         protected void onPostExecute(String result) {
//             Log.e(" setup acc ", "  signup result  " + result);
//             if (dialog.isShowing()) {
//                 dialog.dismiss();
//             }

//             PaytmPGService Service = PaytmPGService.getProductionService();

//             HashMap<String, String> paramMap = new HashMap<String, String>();
//             paramMap.put("MID", mid);
//             paramMap.put("ORDER_ID", orderId);
//             paramMap.put("CUST_ID", customerId);
//             paramMap.put("CHANNEL_ID", "WAP");
//             paramMap.put("TXN_AMOUNT", amount);
//             paramMap.put("WEBSITE", "DEFAULT");
//             paramMap.put("CALLBACK_URL", verifyUrl);
//             paramMap.put("CHECKSUMHASH", CHECKSUMHASH);
//             paramMap.put("INDUSTRY_TYPE_ID", "Retail");

//             PaytmOrder Order = new PaytmOrder(paramMap);
//             Log.e("checksum ", "param " + paramMap.toString());
//             Service.initialize(Order, null);
//             // start payment service call here
//             Service.startPaymentTransaction(MainActivity.this, true, true,
//                     MainActivity.this);


//         }


}

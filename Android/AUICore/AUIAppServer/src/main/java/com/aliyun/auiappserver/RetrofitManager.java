package com.aliyun.auiappserver;

import android.text.TextUtils;
import java.io.IOException;
import java.util.concurrent.TimeUnit;
import okhttp3.Interceptor;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import retrofit2.Retrofit;
import retrofit2.converter.jackson.JacksonConverterFactory;

@SuppressWarnings({"FieldMayBeFinal"})
class RetrofitManager {

    private static Retrofit sRetrofit;
    private static String sEnv = "production";
    private static String sForceServerUrl = "https://appserverjava.h5video.vip";

    static <T> T getService(Class<T> serviceType) {
        return getRetrofit().create(serviceType);
    }

    private static Retrofit getRetrofit() {
        if (sRetrofit == null) {
            String finalServerUrl = sForceServerUrl;
            sRetrofit = new Retrofit.Builder()
                    .baseUrl(finalServerUrl + "/api/v1/")
                    .addConverterFactory(JacksonConverterFactory.create())
                    .addCallAdapterFactory(new ApiInvokerCallAdapterFactory())
                    .client(new OkHttpClient.Builder()
                            .connectTimeout(5, TimeUnit.SECONDS)
                            .readTimeout(10, TimeUnit.SECONDS)
                            .addInterceptor(new Interceptor() {
                                @Override
                                public Response intercept(Chain chain) throws IOException {
                                    Request oldRequest = chain.request();
                                    MediaType contentType = MediaType.get("application/json");
                                    Request.Builder headerBuilder = oldRequest.newBuilder()
                                            .post(new ContentTypeOverridingRequestBody(oldRequest.body(), contentType))
                                            .header("x-live-env", sEnv);
                                    String appServerToken = AppServerTokenManager.getAppServerToken();
                                    if (!TextUtils.isEmpty(appServerToken)) {
                                        headerBuilder.addHeader("Authorization", "Bearer " + appServerToken);
                                    }
                                    return chain.proceed(headerBuilder.build());
                                }
                            })
                            .build()
                    )
                    .build();
        }
        return sRetrofit;
    }

}

package zhenyuyang.ucsb.edu.nachi;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONObject;

import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by Zhenyu on 2017-11-26.
 */

public class PlaceManager{
    private static PlaceManager obj;
    private HashMap<String,Integer> hm = new HashMap<String,Integer>();
    private RequestQueue requestQueue;
    private String api = "AIzaSyDmhZZ8xflY8XYBiQ0KZHAp6_pNIa4Has0";

    private double current_lat;
    private double current_lon;


    private ArrayList<Place> places = new ArrayList<>();

    private PlaceManager(Context context){
        current_lat = -1;
        current_lon = -1;

        // Initialize a new RequestQueue instance
        requestQueue = Volley.newRequestQueue(context);
    }

    public static PlaceManager getInstance(Context context)
    {
        if (obj==null)
            obj = new PlaceManager(context);
        return obj;
    }

    public void addPlace(Place p){
        if(!hm.containsKey(p.name)){
            places.add(p);
            Log.i("PlaceManager","Place -  " + p.name+" added");
        }
        else{
            Log.i("PlaceManager","Place -  " + p.name+" not added, duplicated place found.");
        }

    }

    public Place pop(){

        if(getDataSize()>5){
            return singlePop();
        }
        else if(getDataSize()<=5&&getDataSize()>1){
            fetchRadomPlaces();
            return singlePop();
        }
        else{
            fetchRadomPlaces();
            return null;
        }
    }

    private Place singlePop(){
        SecureRandom randomSeed = new SecureRandom();
        byte seed[] = randomSeed.generateSeed(20);
        SecureRandom random = new SecureRandom(seed);
        int rand =  random.nextInt(places.size());
        Place tempP = places.get(rand);
        places.remove(rand);
        return  tempP;
    }

    public int getDataSize(){
        return places.size();
    }

    public void setLocation(double lat0 ,double lon0){
        current_lat = lat0;
        current_lon = lon0;
    }



    public void fetchRadomPlaces() {
        if (current_lat != -1 && current_lon !=-1) {
            final double lat0 = current_lat;
            final double lon0 = current_lon;

            //https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=34.413684,-119.841981&radius=1500&type=restaurant&key=AIzaSyCVdWYaBgy5qh3x_7bl_yjDl4j_V1baOzM
            //https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=34.413684,-119.841981&radius=1500&type=restaurant&key=AIzaSyBGt0i2o82Mr-ZHP4FKV-HY5jDFvwDALQg
            int radius = 20000; //meters

            SecureRandom randomSeed = new SecureRandom();
            byte seed[] = randomSeed.generateSeed(20);
            SecureRandom random = new SecureRandom(seed);


            int rand = random.nextInt(2 * radius) - radius;
            double dy = rand;
            rand = random.nextInt(2 * radius) - radius;
            double dx = rand;

            Log.i("test", "dx =  " + dx + ", dy = " + dy);

            double lat = lat0 + (180 / Math.PI) * (dy / 6378137);
            double lon = lon0 + (180 / Math.PI) * (dx / 6378137) / Math.cos(lat0);
            Log.i("test", "lat =  " + lat + ", lon = " + lon);

            String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + lat + "," + lon + "&radius=" + 1000 + "&type=restaurant&key=" + api;

            Log.i("test", "sending request, url = " + url);
            JsonObjectRequest jsObjRequest = new JsonObjectRequest
                    (Request.Method.GET, url, null, new Response.Listener<JSONObject>() {

                        @Override
                        public void onResponse(JSONObject response) {

                            try {
                                JSONArray jsonArray_results = response.getJSONArray("results");
                                Log.i("test", "jsonArray_results, length: " + jsonArray_results.length());

                                if (jsonArray_results.length() == 0) {
                                    fetchRadomPlaces();
                                } else {
                                    JSONObject jsonObject = jsonArray_results.getJSONObject(0);

                                    for (int i = 0; i < jsonArray_results.length(); i++) {
                                        jsonObject = jsonArray_results.getJSONObject(i);
                                        Log.i("test", "jsonObject0: " + jsonArray_results.getJSONObject(i).getString("name"));
                                        Place tempP = new Place(jsonArray_results.getJSONObject(i).getString("name"));
                                        addPlace(tempP);
                                    }

                                    if (getDataSize() < 5) {
                                        Log.i("test", "placeManager.getDataSize() = " + getDataSize());
                                        fetchRadomPlaces();
                                    }
                                }
                            } catch (Exception e) {
                                Log.e("Exception", "Exception: " + e.toString());
                            }
                        }
                    }, new Response.ErrorListener() {

                        @Override
                        public void onErrorResponse(VolleyError error) {
                            // TODO Auto-generated method stub

                        }
                    });


            // Add JsonObjectRequest to the RequestQueue
            requestQueue.add(jsObjRequest);
        }
        else{
            Log.e("Exception", "current_lat and current_lon not set");
        }
    }


}

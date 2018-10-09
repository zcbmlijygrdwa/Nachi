package zhenyuyang.ucsb.edu.nachi;

import android.content.Context;
import android.util.Log;

import com.android.volley.toolbox.Volley;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;

/**
 * Created by Zhenyu on 2017-11-29.
 */

public class RoomManager {
    private static RoomManager obj;
    private DatabaseReference mDatabase;
    public String roomName;
    private String myName;
    private ArrayList<Place> placeList;

    // The listener must implement the events interface and passes messages up to the parent.
    private updatePlacesListener updatePlacesListener;

    public interface updatePlacesListener {
        // These methods are the different events and
        // need to pass relevant arguments related to the event triggered
        public void onPlacesUpdated(ArrayList<Place> places);
    }

    private RoomManager(){
        mDatabase = FirebaseDatabase.getInstance().getReference();
        placeList = new ArrayList<>();

        // set null or default listener or accept as argument to constructor
        this.updatePlacesListener = null;

        mDatabase.addChildEventListener(new ChildEventListener() {
            @Override
            public void onChildAdded(DataSnapshot dataSnapshot, String prevChildKey) {}

            @Override
            public void onChildChanged(DataSnapshot dataSnapshot, String prevChildKey) {
                //Post changedPost = dataSnapshot.getValue(Post.class);
                //System.out.println("The updated post title is: " + changedPost.title);
                if(dataSnapshot.getKey().equals(roomName)) {
                    updateRoom(dataSnapshot);
                }
               // Log.i("onChildChanged",dataSnapshot.getValue(String.class));
            }

            @Override
            public void onChildRemoved(DataSnapshot dataSnapshot) {}

            @Override
            public void onChildMoved(DataSnapshot dataSnapshot, String prevChildKey) {}

            @Override
            public void onCancelled(DatabaseError databaseError) {}
        });

    }
    public void setMyName(String myNameIn){
        this.myName = myNameIn;
    }

    public static RoomManager getInstance()
    {
        if (obj==null)
            obj = new RoomManager();
        return obj;
    }

    public void getInstantValue(final String childName){
        //getValue
        mDatabase.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                String value =  (String)dataSnapshot.child(childName).getValue();
                Log.i("test","value at "+childName+" = "+value);
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {

            }
        });
    }

    public void enterRoom(final String roomNameIn){
        this.roomName = processString(roomNameIn);

        mDatabase.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                int placeCount =  (int)dataSnapshot.child(roomName).getChildrenCount();
                Log.i("test","valu  = "+placeCount);


                if(placeCount==0){
                    createRoom();
                }
                else{
                    if (roomName != null) {
                        updateRoom(dataSnapshot.child(roomName));
                    }


                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {

            }
        });

    }

    public void updateRoom(DataSnapshot dataSnapshot) {

            placeList.clear();
            Log.e("Count ", "" + dataSnapshot.getChildrenCount());
            String[] placeNames = new String[(int) dataSnapshot.getChildrenCount()];
            //get places
            int count = 0;
            for (DataSnapshot placeSnapshot : dataSnapshot.getChildren()) {
                //String eachChild = placeSnapshot.getValue(String.class);
                Log.i("Get Data", "place: " + placeSnapshot.getKey());
                placeNames[count++] = (placeSnapshot.getKey());
            }

            //get member for each place
            for (int i = 0; i < placeNames.length; i++) {
                String tempPlaceName = placeNames[i];
                Place place = new Place(tempPlaceName);

                DataSnapshot tempPlace = dataSnapshot.child(tempPlaceName);
                for (DataSnapshot memberSnapshot : tempPlace.getChildren()) {
                    String vote = memberSnapshot.getValue(String.class);

                    place.addMember(memberSnapshot.getKey(), vote);

                    if (place.hm.containsKey(myName)) {
                        if (place.hm.get(myName).equals("0")) {
                            place.isVoted = false;
                        } else {
                            place.isVoted = true;
                        }
                    }
                }
                placeList.add(place);
                //Log.i("Get Data", dataSnapshot.toString());
                //Log.i(placeNames[i]+".toString()", place.toString());
            }

            if (updatePlacesListener != null) {
                updatePlacesListener.onPlacesUpdated(placeList); // <---- fire listener here
            }

    }

    public String processString(String s){
        s = s.replace(".", " ");
        s = s.replace("#", " ");
        s = s.replace("$", " ");
        s = s.replace("[", " ");
        s = s.replace("]", " ");
        return s;
    }

    public  void createRoom(){
        mDatabase.child(roomName).setValue("0");
    }

    public void votePlace(String placeName){
        mDatabase.child(roomName).child(placeName).child(myName).setValue("1");

//        mDatabase.addListenerForSingleValueEvent(new ValueEventListener() {
//            @Override
//            public void onDataChange(DataSnapshot dataSnapshot) {
//                    updateRoom(dataSnapshot);
//            }
//            @Override
//            public void onCancelled(DatabaseError databaseError) {
//
//            }
//            });
    }

    public void unVotePlace(String placeName){
        mDatabase.child(roomName).child(placeName).child(myName).setValue("0");
//        mDatabase.addListenerForSingleValueEvent(new ValueEventListener() {
//            @Override
//            public void onDataChange(DataSnapshot dataSnapshot) {
//                updateRoom(dataSnapshot);
//            }
//            @Override
//            public void onCancelled(DatabaseError databaseError) {
//
//            }
//        });
    }

    public void addGroupMember(String memberName){
        mDatabase.child(roomName).child(memberName).setValue("0");
    }

    public void addPlace(String placeName){
        mDatabase.child(roomName).child(processString(placeName)).child(myName).setValue("1");
    }


    public void setValueAtChild(String childName, int value){
        //setValue
        mDatabase.child(childName).setValue(""+value);
    }

    public void createChildWithvalue(String childName, int value){
        //setValue
        mDatabase.child(childName).setValue(""+value);
    }

    public void removeChild(String childName){
        //remove
        mDatabase.child(childName).removeValue();
    }

    public ArrayList<Place> getPlaces(){
        return placeList;
    }

    // Assign the listener implementing events interface that will receive the events
    public void setUpdatePlacesListener(updatePlacesListener listener) {
        this.updatePlacesListener = listener;
    }

}

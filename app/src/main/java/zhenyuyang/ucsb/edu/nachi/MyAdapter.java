package zhenyuyang.ucsb.edu.nachi;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by Zhenyu on 2017-11-29.
 */

public class MyAdapter extends RecyclerView.Adapter<MyAdapter.ViewHolder> {

    private ArrayList<Place> places;


    public MyAdapter(ArrayList<Place> placesIn){
        this.places = placesIn;
    }

    // Provide a direct reference to each of the views within a data item
    // Used to cache the views within the item layout for fast access
    public class ViewHolder extends RecyclerView.ViewHolder {
        // Your holder should contain a member variable
        // for any view that will be set as you render a row
        public TextView place_name;
        public TextView members_textview;
        public Button messageButton;

        // We also create a constructor that accepts the entire item row
        // and does the view lookups to find each subview
        public ViewHolder(View itemView) {
            // Stores the itemView in a public final member variable that can be used
            // to access the context from any ViewHolder instance.
            super(itemView);

            place_name = (TextView) itemView.findViewById(R.id.place_name);
            members_textview = (TextView) itemView.findViewById(R.id.members_textview);
            messageButton = (Button) itemView.findViewById(R.id.button_vote);
        }
    }

    // Usually involves inflating a layout from XML and returning the holder
    @Override
    public MyAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);

        // Inflate the custom layout
        View contactView = inflater.inflate(R.layout.placeview, parent, false);

        // Return a new holder instance
        ViewHolder viewHolder = new ViewHolder(contactView);
        return viewHolder;
    }


    // Involves populating data into the item through holder
    @Override
    public void onBindViewHolder(MyAdapter.ViewHolder viewHolder, int position) {
        // Get the data model based on position
        final Place place = places.get(position);

        // Set item views based on your views and data model
        TextView place_name = viewHolder.place_name;
        place_name.setText(place.name);
        TextView members_textview = viewHolder.members_textview;
        members_textview.setText(place.toString());
        Log.i("MyAdapter","place.voteStatus() = "+place.voteStatus());
        Button button = viewHolder.messageButton;
        button.setText(place.isVoted ? "Unvote" : "Vote");
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(place.isVoted==false){
                    RoomManager rm = RoomManager.getInstance();
                    rm.votePlace(place.name);
                }
                else{
                    RoomManager rm = RoomManager.getInstance();
                    rm.unVotePlace(place.name);
                }

            }
        });
       // button.setEnabled(place.isOnline());
    }

    // Returns the total count of items in the list
    @Override
    public int getItemCount() {
        return places.size();
    }

    public void setPlaces(ArrayList<Place> placesIn){
        this.places = placesIn;
        notifyDataSetChanged();
    }


    public void clear() {
        int size = this.places.size();
        this.places.clear();
        notifyItemRangeRemoved(0, size);
    }
}
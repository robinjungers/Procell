import twitter4j.*;
import twitter4j.api.*;
import twitter4j.auth.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.management.*;
import twitter4j.util.*;
import twitter4j.util.function.*;

import java.util.Date;

class TwitterReader {

  private TwitterFactory twitterFactory;
  private Twitter twitter;
  private RequestToken requestToken;

  private Query query;
  private QueryResult result;

  private ArrayList tweets;
  private ArrayList<Integer> humours;

  private String msg, user, pseudo;

  TwitterReader() {

    this.query = new Query( "default" );
    this.query.setCount( 100 );

    ConfigurationBuilder cb = new ConfigurationBuilder();

    cb.setOAuthConsumerKey( "PDK4d1s3w1CjBwC3wLIezZkMM" );
    cb.setOAuthConsumerSecret( "W6YInJhGLKASOqe3ngoJjOpMcyFKegjypFjtZIVERFZpxxdpeV" );
    cb.setOAuthAccessToken( "116720199-54LaxdHHT9l22woakmqBM4r9NBBviMKBStRxt571" );
    cb.setOAuthAccessTokenSecret( "ela7Fx70QPH9g2E95kA3gs0ls8VhEh72M9ORY5ar1G9ag" );

    this.twitterFactory = new TwitterFactory( cb.build() );
    this.twitter = twitterFactory.getInstance();

    this.humours = new ArrayList<Integer>();
  }

  public void setTopic( String topic ) {
    this.query = new Query( topic );
    this.query.setCount( 100 );
  }

  public void getResults() {
    try {
      this.result = twitter.search( this.query );
      this.tweets = (ArrayList) this.result.getTweets();
    } 
    catch ( TwitterException e ) {
      println("Couldn't connect: " + e);
    }
  }

  public void evaluateHumours() {
  }

  public void printResults() {
    for ( int i = 0; i < tweets.size(); i++ ) {
      Status t = (Status) tweets.get(i);
      println( "Tweet n°" + (i+1) + " : " + t.getText().replace( "\n", "" ) );
    }
  }

  public void buildEntities( ArrayList<Entity> list ) {
    list.clear();

    for ( int i = 0; i < 10; i++ ) {
      float x = noise( i );
      float y = noise( x, i );
      Virus virus = new Virus( x*sceneSize.x, y*sceneSize.y );
      list.add( virus );
    }
    for ( int i = 10; i < 20; i++ ) {
      float x = noise( i );
      float y = noise( x, i );
      Microbe microbe = new Microbe( x*sceneSize.x, y*sceneSize.y );
      list.add( microbe );
    }
    for ( int i = 20; i < 30; i++ ) {
      float x = noise( i );
      float y = noise( x, i );
      Bacteria bacteria = new Bacteria( x*sceneSize.x, y*sceneSize.y );
      list.add( bacteria );
    }
    for ( int i = 30; i < 40; i++ ) {
      float x = noise( i );
      float y = noise( x, i );
      Grower grower = new Grower( x*sceneSize.x, y*sceneSize.y );
      entities.add( grower );
    }
  }
}
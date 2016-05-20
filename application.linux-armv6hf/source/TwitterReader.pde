import twitter4j.*;
import twitter4j.api.*;
import twitter4j.auth.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.management.*;
import twitter4j.util.*;
import twitter4j.util.function.*;

import java.util.Date;

/**
 * TwitterReader is the class providing tools to fetch Twitter data.
 * <p>
 * The TwitterReader is characterized by the next information :
 * <ul>
 * <li> A twitterFactory, which allows to constructs Twitter instances from authentification
 * <li> A twitter, the actual instance of the twitterFactory
 * <li> A query, which stores the request and its settings
 * <li> A result, which will store the response from Twitter to the query
 * <li> A tweets to collect all the Tweets from the result
 * </ul>
 * </p>
*/
class TwitterReader {
  
  /**
  * The TwitterFactory is used to stores personnal twitter oAuth keys and get instances of Twitter
  * @see TwitterFactory
  * @see Twitter
  */
  private TwitterFactory twitterFactory;
  
  /**
  * The twitter is the actual instance of the TwitterFactory, through which we can send and receive data.
  *
  * @see TwitterReader#getResults()
  * @see Twitter
  * @see TwitterFactory
  */
  private Twitter twitter;
  
  /**
  * The query can store the Strinf for the reserch and its parameters
  *
  * @see TwitterReader#getResults()
  * @see Query
  * @see Twitter
  */
  private Query query;
  
  /**
  * The result will store the results from twitter after having sent a query
  *
  * @see TwitterReader#getResults()
  * @see Query
  * @see Twitter
  */
  private QueryResult result;

  /**
  * The tweets is a collection of all the received tweets from a response
  *
  * @see TwitterReader#getResults()
  * @see Query
  * @see Twitter
  */
  private ArrayList tweets;
  
  /**
  * TwitterReader Constructor.
  * <p>
  * When a TwitterReader is constructed, its query is by default set "default", with a 100 count response
  * A ConfigurationBuilder is set with Twitter keys
  * The twitterFactory is initialized with it
  * The twitter gets an instance out of the twitterFactory
  * </p>
  */
  public TwitterReader() {

    this.query = new Query( "default" );
    this.query.setCount( 100 );

    ConfigurationBuilder cb = new ConfigurationBuilder();

    cb.setOAuthConsumerKey( "PDK4d1s3w1CjBwC3wLIezZkMM" );
    cb.setOAuthConsumerSecret( "W6YInJhGLKASOqe3ngoJjOpMcyFKegjypFjtZIVERFZpxxdpeV" );
    cb.setOAuthAccessToken( "116720199-54LaxdHHT9l22woakmqBM4r9NBBviMKBStRxt571" );
    cb.setOAuthAccessTokenSecret( "ela7Fx70QPH9g2E95kA3gs0ls8VhEh72M9ORY5ar1G9ag" );

    this.twitterFactory = new TwitterFactory( cb.build() );
    this.twitter = twitterFactory.getInstance();
  }

  /**
  * Setter for the query with a new topic
  *
  * @param topic
  *          The topic string to set
  *
  * @see TwitterReader#query
  */
  public void setTopic( String topic ) {
    this.query = new Query( topic );
    this.query.setCount( 100 );
    this.query.resultType( Query.MIXED );
  }
  
  /**
  * Method for Twitter communication. The query is sent, an answer is returned.
  *
  * @see TwitterReader#query
  * @see TwitterReader#result
  * @see TwitterReader#tweets
  */
  public void getResults() {
    try {
      this.result = twitter.search( this.query );
      this.tweets = (ArrayList) this.result.getTweets();
    } 
    catch ( TwitterException e ) {
      println("Couldn't connect: " + e);
    }
  }
  
  /**
  * Method for Twitter results printing
  *
  * @see TwitterReader#query
  * @see TwitterReader#result
  * @see TwitterReader#tweets
  */
  public void printResults() {
    for ( int i = 0; i < this.tweets.size(); i++ ) {
      Status t = (Status) this.tweets.get(i);
      println( "Tweet n°" + (i+1) + " : " + t.getText().replace( "\n", "" ) );
    }
  }
  
  /**
  * Entities initializer
  *
  * @param list
  *          The arraylist of Entities in which new entities will be stored
  *
  * @param sceneSize
  *          The dimension within the entities will be constructed
  *
  * @see Entity
  * @see Virus
  * @see Bacteria
  * @see Microbe
  * @see Grower
  * @see TwitterReader#tweets
  */
  public void buildEntities( ArrayList<Entity> list, PVector sceneSize ) {
    list.clear();
    
    for ( int i = 0; i < this.tweets.size(); i++ ) {
      Status t = (Status) this.tweets.get(i);
      StringBuilder s = new StringBuilder( t.getText().replace( "\n", "" ) );
      int indexOfLink = s.indexOf( "http" );
      if ( indexOfLink > 0 )
        s.setLength( indexOfLink );
      println( "Entity n°" + i + " : " + s.toString() );
      if ( s.length() > 60 )
        s.insert( 60, '\n' );
      if ( s.length() > 120 )
        s.insert( 120, '\n' );
      
      Entity e;
      
      float x = noise( i );
      float y = noise( x, i );
      float z = 40 + 0.04*t.getFavoriteCount();
      
      switch ( (int)(random(4.9)) ) {
        case 0:
          e = new Virus( x*sceneSize.x, y*sceneSize.y, z );
        break;
        case 1:
          e = new Bacteria( x*sceneSize.x, y*sceneSize.y, z );
        break;
        case 2:
          e = new Grower( x*sceneSize.x, y*sceneSize.y, z );
        break;
        case 3:
          e = new Microbe( x*sceneSize.x, y*sceneSize.y, z );
        break;
        case 4:
          e = new Virus( x*sceneSize.x, y*sceneSize.y, z );
        break;
        default:
          e = new Virus( x*sceneSize.x, y*sceneSize.y, z );
        break;
      }
      
      e.setSpeech( s.toString() );
      list.add( e );
      
    }

  }
}
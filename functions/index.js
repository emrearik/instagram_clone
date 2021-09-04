const functions = require("firebase-functions");

const admin = require('firebase-admin');
admin.initializeApp();

exports.onFollowUser = functions.firestore.document('followers/{userID}/userFollowers/{followerID}')
.onCreate(async (_,context)=> {
    const userID = context.params.userID;
    const followerID = context.params.followerID;

    //Increment followed user's followers count.
    const followedUserRef = admin.firestore().collection('users').doc(userID);
    const followedUserDoc = await followedUserRef.get();
    
    if(followedUserDoc.get('followers') !== undefined){
        followedUserRef.update({
            followers : followedUserDoc.get('followers')+1,
        });
    }else {
        followedUserRef.update({followers:1});
    }

    //Increment user's following count
    const userRef = admin.firestore().collection('users').doc(followerID);
    const userDoc = await userRef.get();
    if(userDoc.get('following') !== undefined){
        userRef.update({following: userDoc.get('following') +1});
    }else {
        userRef.update({following:1});
    }

    //Add followed user's posts to user's posts feed.
    const followedUserPostsRef = admin.firestore().collection('posts').where('author' ,'==' , followedUserRef);
    const userFeedRef = admin.firestore().collection('feeds').doc(followerID).collection('userFeed');
    const followedUserPostsSnapshot = await followedUserPostsRef.get();
    followedUserPostsSnapshot.forEach((doc) => {
        if(doc.exists){
            userFeedRef.doc(doc.id).set(doc.data());
        }
    });
});

exports.onUnfollowUser = functions.firestore.document('/followers/{userID}/userFollowers/{followerID}').onDelete(async (_,context) => {
    const userID = context.params.userID;
    const followerID = context.params.followerID;

    //Decrement unfollowed user's followers count.
    const followedUserRef = admin.firestore().collection('users').doc(userID);
    const followedUserDoc = await followedUserRef.get();

    if(followedUserDoc.get('followers') !== undefined){
        followedUserRef.update({
            followers: followedUserDoc.get('followers') -1,
        });
    }else {
        followedUserRef.update({followers:0});
    }

    //Decrement user's following count.
    const userRef = admin.firestore().collection('users').doc(followerID);
    const userDoc = await userRef.get();
    if(userDoc.get('following') !== undefined ){
        userRef.update({following: userDoc.get('following') -1});
    }else {
        userRef.update({following:0});
    }

    //Remove unfollowed user's posts from user's post feed.
    const userFeedRed = admin.firestore().collection('feeds').doc(followerID).collection('userFeed').where('author','==',followedUserRef);
    const userPostsSnapshot = await userFeedRed.get();
    userPostsSnapshot.forEach((doc) => {
        if(doc.exists){
            doc.ref.delete();
        }
    })
});

exports.onCreatePost = functions.firestore.document('/posts/{postID}').onCreate(async (snapshot,context) => {
    const postID = context.params.postID;

    //Get author id.
    const authorRef = snapshot.get('author');
    const authorID = authorRef.path.split('/')[1];

    //Add new post to feeds of all followers.
    const userFollowersRef = admin.firestore().collection('followers').doc(authorID).collection('userFollowers');

    const userFollowersSnapshot = await userFollowersRef.get();
    userFollowersSnapshot.forEach((doc)=> {
        admin.firestore().collection('feeds').doc(doc.id).collection('userFeed').doc(postID).set(snapshot.data());
    });

});

exports.onUpdatePost = functions.firestore.document('/posts/{postID}').onUpdate(async (snapshot,context) => {
    const postID = context.params.postID;

     //Get author id.
     const authorRef = snapshot.after.get('author');
     const authorID = authorRef.path.split('/')[1];

     //Update post data in each follower's feed.
     const updatedPostData = snapshot.after.data();
     const userFollowersRef = admin.firestore().collection('followers').doc(authorID).collection('userFollowers');
     const userFollowersSnapshot = await userFollowersRef.get();

     userFollowersSnapshot.forEach(async(doc)=> {
        const postRef = admin.firestore().collection('feeds').doc(doc.id).collection('userFeed');
        const postDoc = await postRef.doc(postID).get();
   
        if(postDoc.exists){
            postDoc.ref.update(updatedPostData);
        }
     });

});
package com.boyaa.cocoslib.facebook;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.boyaa.cocoslib.core.Cocos2dxActivityWrapper;
import com.boyaa.cocoslib.core.IPlugin;
import com.boyaa.cocoslib.core.LifecycleObserverAdapter;
import com.facebook.AppEventsLogger;
import com.facebook.FacebookAuthorizationException;
import com.facebook.FacebookException;
import com.facebook.FacebookOperationCanceledException;
import com.facebook.FacebookRequestError;
import com.facebook.Request;
import com.facebook.Settings;
import com.facebook.Request.Callback;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.Session.NewPermissionsRequest;
import com.facebook.Session.OpenRequest;
import com.facebook.SessionState;
import com.facebook.UiLifecycleHelper;
import com.facebook.widget.FacebookDialog;
import com.facebook.widget.WebDialog;
import com.facebook.widget.WebDialog.OnCompleteListener;

public class FacebookPlugin extends LifecycleObserverAdapter implements IPlugin {
	private static final String TAG = FacebookPlugin.class.getSimpleName();
	private static final String PENDING_ACTION_BUNDLE_KEY = "com.boyaa.cocoslib.facebook:PendingAction";
	private static enum PendingAction {
        NONE(null),
        LOGIN(null),
        INVITE(null),
        GET_REQUEST_ID(null),
        INVITABLE_FRIENDS("user_friends"),
        SHARE_FEED(null);
        private List<String> permissions;
        private PendingAction(String permissions) {
        	if(!TextUtils.isEmpty(permissions)) {
        		this.permissions = new ArrayList<String>();
        		this.permissions.addAll(Arrays.asList(permissions.split(",")));
        	}
        }
        @SuppressWarnings("unused")
		public List<String> getPermissions() {
        	return permissions;
        }
        public boolean isAllPermissionGranted(Session session) {
        	boolean allPermissionGranted = true;
    		if(permissions != null) {
    			for(String permission : permissions) {
    				if(!session.isPermissionGranted(permission)) {
    					allPermissionGranted = false;
    					break;
    				}
    			}
    		}
    		return allPermissionGranted && session.isOpened();
        }
        public List<String> getPendingPermissions(Session session, int type) {
        	List<String> pendingPermission = new ArrayList<String>();
        	if(permissions != null) {
    			for(String permission : permissions) {
		        	if(type == 1) {
		        		//read permission
		        		if(!Session.isPublishPermission(permission) && !session.isPermissionGranted(permission)) {
		        			pendingPermission.add(permission);
		        		}
		        	} else if(type == 2) {
		        		//publish permission
		        		if(Session.isPublishPermission(permission) && !session.isPermissionGranted(permission)) {
		        			pendingPermission.add(permission);
		        		}
		        	}
    			}
        	}
        	if(pendingPermission.size() == 0 && !session.isOpened()) {
        		pendingPermission.add("email");
        		pendingPermission.add("user_friends");
        	}
        	return pendingPermission;
        }
    }
	private String pluginId;
	private PendingAction pendingAction = PendingAction.NONE;
	private UiLifecycleHelper uiHelper;
	private boolean isPenddingPermission = false;
	private String inviteData;
	private String inviteMessage;
	private String inviteToIds;
	private String inviteTitle;
	private String feedData;
//	private boolean canPresentShareDialog;
//  private boolean canPresentShareDialogWithPhotos;
	
	private String invitableLimit;
	
	
	@Override
	public void initialize() {
		Cocos2dxActivityWrapper.getContext().addObserver(this);
	}

	@Override
	public void setId(String id) {
		pluginId = id;
	}
	
	public String getId() {
		return pluginId;
	}
	
	public void login() {
		Log.d(TAG, "login");
		pendingAction = PendingAction.NONE;
		try {
			Session session = Session.getActiveSession();
			if(session.isOpened()) {
				Date expire = session.getExpirationDate();
				long exptime = expire.getTime();
				String accessToken = session.getAccessToken();
				if(expire != null && expire.compareTo(new Date()) > 0) {
					Log.d(TAG, "already logged in");
					try {
						JSONObject json = new JSONObject();
						json.put("accessToken", accessToken);
						json.put("exptime", exptime);
						FacebookBridge.callLuaLogin(accessToken, false);
					} catch (Exception e) {
						// TODO: handle exception
					}
					
					return;
				}
			} else if(session.isClosed()) {
				session.removeCallback(callback);
				session.closeAndClearTokenInformation();
				session = new Session(Cocos2dxActivityWrapper.getContext());
				session.addCallback(callback);
				Session.setActiveSession(session);
			}
			pendingAction = PendingAction.LOGIN;
			if(session.getState() != SessionState.OPENING) {
				Log.d(TAG, "request permission");
				List<String> permissions = new ArrayList<String>();
				permissions.add("email");
				permissions.add("user_friends");
				if(session.isOpened()) {
					session.requestNewReadPermissions(new NewPermissionsRequest(Cocos2dxActivityWrapper.getContext(), permissions).setCallback(callback));
				} else {
					session.openForRead(new OpenRequest(Cocos2dxActivityWrapper.getContext()).setCallback(callback).setPermissions(permissions));
				}
			}
		} catch(Exception e) {
			Log.e(TAG, e.getMessage(), e);
		}
	}
	
	public void logout() {
		pendingAction = PendingAction.NONE;
		Session session = Session.getActiveSession();
		if(session != null) {
			session.removeCallback(callback);
			session.closeAndClearTokenInformation();
		}
		session = new Session(Cocos2dxActivityWrapper.getContext());
		session.addCallback(callback);
		Session.setActiveSession(session);
	}
	
	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		isPenddingPermission = false;
		uiHelper = new UiLifecycleHelper(activity, callback);
		uiHelper.onCreate(savedInstanceState);
		if (savedInstanceState != null) {
			String name = savedInstanceState.getString(PENDING_ACTION_BUNDLE_KEY);
			pendingAction = PendingAction.valueOf(name);
		}
		// Can we present the share dialog for regular links?
//		canPresentShareDialog = FacebookDialog.canPresentShareDialog(activity, FacebookDialog.ShareDialogFeature.SHARE_DIALOG);
		// Can we present the share dialog for photos?
//		canPresentShareDialogWithPhotos = FacebookDialog.canPresentShareDialog(activity, FacebookDialog.ShareDialogFeature.PHOTOS);
	}

	@Override
	public void onResume(Activity activity) {
		uiHelper.onResume();
		AppEventsLogger.activateApp(activity);
	}
	
	@Override
	public void onSaveInstanceState(Activity activity, Bundle outState) {
        uiHelper.onSaveInstanceState(outState);
        if(outState != null && pendingAction != null) {
        	outState.putString(PENDING_ACTION_BUNDLE_KEY, pendingAction.name());
        }
    }
	
	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        uiHelper.onActivityResult(requestCode, resultCode, data, dialogCallback);
    }

    @Override
    public void onPause(Activity activity) {
        uiHelper.onPause();
        AppEventsLogger.deactivateApp(activity);
    }

	@Override
	public void onDestroy(Activity activity) {
	    uiHelper.onDestroy();
	}

	private Session.StatusCallback callback = new Session.StatusCallback() {
        @Override
        public void call(Session session, SessionState state, Exception exception) {
            onSessionStateChange(session, state, exception);
        }
    };
    private void onSessionStateChange(Session session, SessionState state, Exception exception) {
    	Log.d(TAG, "onSessionStateChange session:" + session + " state:" + state.name() + ", exception:" + exception);
        if(pendingAction != PendingAction.NONE && exception != null &&
                (exception instanceof FacebookOperationCanceledException ||
                exception instanceof FacebookAuthorizationException)) {
            //取消或者授权失败
        	isPenddingPermission = false;
        	handlePendingAction(false, exception instanceof FacebookOperationCanceledException ? "canceled" : "failed" );
        } else if(state == SessionState.OPENED_TOKEN_UPDATED) {
        	isPenddingPermission = false;
        	if(pendingAction != PendingAction.NONE) {
        		if(pendingAction.isAllPermissionGranted(session)) {
        			handlePendingAction(true, null);
        		} else {
        			requestPermission(session, pendingAction);
        		}
        	}
        } else if(state == SessionState.CREATED_TOKEN_LOADED) {
        	if(pendingAction != null) {
        		if(pendingAction.isAllPermissionGranted(session)) {
        			handlePendingAction(true, null);
        		} else if(!isPenddingPermission) {
        			requestPermission(session, pendingAction);
        		}
        	}
        } else if(state == SessionState.OPENED) {
        	if(pendingAction != null) {
        		if(pendingAction.isAllPermissionGranted(session)) {
        			handlePendingAction(true, null);
        		} else if(!isPenddingPermission) {
        			requestPermission(session, pendingAction);
        		}
        	}
        }
    }
    
    private void requestPermission(Session session, PendingAction pendingAction) {
    	List<String> permissions = pendingAction.getPendingPermissions(session, 1);
		if(permissions != null && permissions.size() > 0) {
			Log.d(TAG, "request read permission" + Arrays.toString(permissions.toArray()));
			if(session.isOpened()) {
				session.requestNewReadPermissions(new NewPermissionsRequest(Cocos2dxActivityWrapper.getContext(), permissions));
			} else {
			    try{
                    Session newsession = new Session.Builder(Cocos2dxActivityWrapper.getContext())
                            .setApplicationId(Settings.getApplicationId()).build();
                    Session.setActiveSession(newsession);
                    session = newsession;
                    session.openForRead(new OpenRequest(Cocos2dxActivityWrapper.getContext()).setCallback(callback).setPermissions(permissions));
                }catch(Exception e){
                    e.printStackTrace();
                }
//				session.openForRead(new OpenRequest(Cocos2dxActivityWrapper.getContext()).setCallback(callback).setPermissions(permissions));
			}
		} else {
			permissions = pendingAction.getPendingPermissions(session, 2);
			if(permissions != null && permissions.size() > 0) {
				Log.d(TAG, "request publish permission" + Arrays.toString(permissions.toArray()));
				if(session.isOpened()) {
					session.requestNewPublishPermissions(new NewPermissionsRequest(Cocos2dxActivityWrapper.getContext(), permissions));
				} else {
					session.openForPublish(new OpenRequest(Cocos2dxActivityWrapper.getContext()).setCallback(callback).setPermissions(permissions));
				}
			}
		}
    }
    
    private void handlePendingAction(boolean isPermissionUpdated, String reason) {
    	Log.d(TAG, "handlePendingAction " + isPermissionUpdated + " " + reason);
        PendingAction previouslyPendingAction = pendingAction;
        // These actions may re-set pendingAction if they are still pending, but we assume they
        // will succeed.
        pendingAction = PendingAction.NONE;

        switch (previouslyPendingAction) {
        	case LOGIN:
        		doLogin(isPermissionUpdated, reason);
        		break;
            case INVITE:
                doInvite(isPermissionUpdated, reason);
                break;
            case SHARE_FEED:
                doShareFeed(isPermissionUpdated, reason);
                break;
            case INVITABLE_FRIENDS:
            	doGetInvitableFriends(isPermissionUpdated, reason);
            	break;
            case GET_REQUEST_ID:
            	doGetRequestId(isPermissionUpdated, reason);
            	break;
            case NONE:
            	break;
        }
    }
    
    private void doGetInvitableFriends(boolean isPermissionUpdated, String reason) {
    	if(isPermissionUpdated) {
    	    Request invitableFriendsRequest = Request.newGraphPathRequest(Session.getActiveSession(), "me/invitable_friends", new Callback() {
				@Override
				public void onCompleted(Response response) {
					FacebookRequestError error = response.getError();
					if(error != null) {
						Log.e(TAG, "invitable_friends error" + error.toString());
						FacebookBridge.callLuaInvitableFriendsResult("failed", true);
					} else {
						String rawStr = response.getRawResponse();
						Log.d(TAG, "invitable_friends ret->" + rawStr);
						try {
							JSONObject rawJson = new JSONObject(rawStr);
							JSONArray dataArr = rawJson.getJSONArray("data");
							int len = dataArr.length();
							JSONArray arr = new JSONArray();
							for(int i = 0; i < len; i++) {
								JSONObject row = dataArr.getJSONObject(i);
								JSONObject picture = row.getJSONObject("picture");
								JSONObject retJson = new JSONObject();
								retJson.put("id", row.optString("id"));
								retJson.put("name", row.optString("name"));
								if(picture != null) {
									JSONObject data = picture.optJSONObject("data");
									if(data != null) {
										retJson.put("url", data.optString("url"));
									}
								}
								arr.put(retJson);
							}
							FacebookBridge.callLuaInvitableFriendsResult(arr.toString(), true);
						} catch(Exception e) {
							Log.e(TAG, e.getMessage(), e);
							FacebookBridge.callLuaInvitableFriendsResult("failed", true);
						}
					}
				}
	    	});
    	    
    	    if(invitableLimit != null && invitableLimit.length() > 0)
    	    {
    	    	Bundle invitableParams = new Bundle();
        	    invitableParams.putString("limit", invitableLimit);
        	    invitableFriendsRequest.setParameters(invitableParams);
    	    }
    	    
    	    invitableFriendsRequest.executeAsync();
    	} else {
    		FacebookBridge.callLuaInvitableFriendsResult(reason, true);
    	}
    }
    
    private void doGetRequestId(boolean isPermissionUpdated, String reason) {
    	if(isPermissionUpdated) {
    		Request.newGraphPathRequest(Session.getActiveSession(), "me/apprequests", new Callback() {
				@Override
				public void onCompleted(Response response) {
					FacebookRequestError error = response.getError();
					if(error != null) {
						Log.e(TAG, "get apprequests error" + error.toString());
						FacebookBridge.callLuaGetRequestIdResult("failed", true);
					} else {
						String rawStr = response.getRawResponse();
						Log.d(TAG, "get apprequests ret->" + rawStr);
						try {
							JSONObject rawJson = new JSONObject(rawStr);
							JSONArray dataArr = rawJson.getJSONArray("data");
							JSONObject ret = new JSONObject();
							if(dataArr != null && dataArr.length() > 0) {
								JSONObject json = dataArr.getJSONObject(0);
								String requestId = json.optString("id");
								String requestData = json.optString("data");
								ret.putOpt("requestId", requestId);
								ret.putOpt("requestData", requestData);
							}
							FacebookBridge.callLuaGetRequestIdResult(ret.toString(), true);
						} catch(Exception e) {
							Log.e(TAG, e.getMessage(), e);
							FacebookBridge.callLuaGetRequestIdResult("failed", true);
						}
					}
				}
	    	}).executeAsync();
    	} else {
			FacebookBridge.callLuaGetRequestIdResult(reason, true);
		}
    }

	private void doInvite(boolean isPermissionUpdated, String reason) {
		if(isPermissionUpdated) {
			final Bundle params = new Bundle();
		    params.putString("message", inviteMessage);
		    params.putString("title", inviteTitle);
		    params.putString("to", inviteToIds);
		    params.putString("data", inviteData);
		    
		    WebDialog requestsDialog = (new WebDialog.RequestsDialogBuilder(Cocos2dxActivityWrapper.getContext(), Session.getActiveSession(), params))
		    		.setOnCompleteListener(new OnCompleteListener() {
						@Override
						public void onComplete(Bundle values, FacebookException error) {
							if (error != null) {
							    error.printStackTrace();
								if (error instanceof FacebookOperationCanceledException) {
									FacebookBridge.callLuaInviteResult("canceled", true);
								} else {
									FacebookBridge.callLuaInviteResult("failed", true);
								}
							} else if(values != null) {
								String requestId = values.getString("request");
								if(requestId != null) {
									Iterator<String> it = values.keySet().iterator();
									Pattern p = Pattern.compile("^to\\[(\\d+)\\]$");
									StringBuilder idSb = new StringBuilder();
									while(it.hasNext()) {
										String key = it.next();
										if(p.matcher(key).matches()) {
											if(idSb.length() > 0) {
												idSb.append(",");
											}
											idSb.append(values.getString(key));
										}
									}
									JSONObject json = new JSONObject();
									try {
										json.put("requestId", requestId);
										json.put("toIds", idSb.toString());
									} catch(Exception e) {
										Log.e(TAG, e.getMessage(), e);
									}
									FacebookBridge.callLuaInviteResult(json.toString(), true);
								} else {
									FacebookBridge.callLuaInviteResult("canceled", true);
								}
							}
						}
					})
					.build();
		    requestsDialog.show();
		} else {
			FacebookBridge.callLuaInviteResult(reason, true);
		}
	}
	
	private void doLogin(boolean isPermissionUpdated, String reason) {
		Log.d(TAG, "doLogin");
		if(isPermissionUpdated) {
			String accessToken = Session.getActiveSession().getAccessToken();
			Date expire = Session.getActiveSession().getExpirationDate();
			long exptime = expire.getTime();
			try {
				JSONObject json = new JSONObject();
				json.put("accessToken", accessToken);
				json.put("exptime", exptime);
				FacebookBridge.callLuaLogin(accessToken, true);
			} catch (Exception e) {
				// TODO: handle exception
			}
		} else {
			FacebookBridge.callLuaLogin(reason, true);
		}
	}
	
	private void doShareFeed(boolean isPermissionUpdated, String reason) {
		if(isPermissionUpdated) {
			try {
				JSONObject json = new JSONObject(feedData);
				Bundle params = new Bundle();
			    params.putString("name", json.optString("name"));
			    params.putString("caption", json.optString("caption"));
			    params.putString("message", json.optString("message"));
			    params.putString("link", json.optString("link"));
			    params.putString("picture", json.optString("picture"));
			    /*
			    new Request(Session.getActiveSession(), "me/feed", params, HttpMethod.POST, new Callback() {
					@Override
					public void onCompleted(Response response) {
						FacebookRequestError error = response.getError();
						if(error != null) {
							Log.e(TAG, "doShareFeed error" + error.toString());
							FacebookBridge.callLuaShareFeedResult("failed", true);
						} else {
							String rawStr = response.getRawResponse();
							Log.d(TAG, "doShareFeed ret->" + rawStr);
							try {
								JSONObject json = new JSONObject(rawStr);
								FacebookBridge.callLuaShareFeedResult(json.getString("id"), true);
							} catch(Exception e) {
								Log.e(TAG, e.getMessage(), e);
								FacebookBridge.callLuaShareFeedResult(rawStr, true);
							}
						}
					}
			    }).executeAsync();
			    */
			    
			    WebDialog feedDialog = (
				        new WebDialog.FeedDialogBuilder(Cocos2dxActivityWrapper.getContext(),
				            Session.getActiveSession(),
				            params))
				        .setOnCompleteListener(new OnCompleteListener() {
				            @Override
				            public void onComplete(Bundle values, FacebookException error) {
				                if (error == null) {
				                    // When the story is posted, echo the success
				                    // and the post Id.
				                    final String postId = values.getString("post_id");
				                    if (postId != null) {
				                    	FacebookBridge.callLuaShareFeedResult(postId, true);
				                    } else {
				                        // User clicked the Cancel button
				                    	FacebookBridge.callLuaShareFeedResult("canceled", true);
				                    }
				                } else if (error instanceof FacebookOperationCanceledException) {
				                    // User clicked the "x" button
				                	FacebookBridge.callLuaShareFeedResult("canceled", true);
				                } else {
				                    // Generic, ex: network error
				                	FacebookBridge.callLuaShareFeedResult("failed", true);
				                }
				            }
	
				        })
				        .build();
				    feedDialog.show();
				 
			} catch(Exception e) {
				Log.e(TAG, e.getMessage(), e);
			}
		} else {
			FacebookBridge.callLuaShareFeedResult(reason, true);
		}
	}

	private FacebookDialog.Callback dialogCallback = new FacebookDialog.Callback() {
        @Override
        public void onError(FacebookDialog.PendingCall pendingCall, Exception error, Bundle data) {
            Log.d(TAG, String.format("Error: %s", error.toString() + " " + (pendingCall != null ? pendingCall.toString() : null) + " " + (data != null ? data.toString() : null)));
        }
        @Override
        public void onComplete(FacebookDialog.PendingCall pendingCall, Bundle data) {
            Log.d(TAG, "Success!" + pendingCall.toString() + " " + data.toString());
        }
    };

	public void sendInvites(final String data, final String toIds, final String title, final String message) {
		pendingAction = PendingAction.INVITE;
		inviteMessage = message;
		inviteToIds = toIds;
		inviteTitle = title;
		inviteData = data;
		Session session = Session.getActiveSession();
		if(pendingAction.isAllPermissionGranted(session)) {
			handlePendingAction(true, null);
		} else if(!isPenddingPermission) {
			requestPermission(session, pendingAction);
		}
	}
	
	public void getInvitableFriends(String limit) {
		invitableLimit = limit;
		pendingAction = PendingAction.INVITABLE_FRIENDS;
		Session session = Session.getActiveSession();
		if(pendingAction.isAllPermissionGranted(session)) {
			handlePendingAction(true, null);
		} else if(!isPenddingPermission) {
			requestPermission(session, pendingAction);
		}
	}
	
	public void shareFeed(String params) {
		pendingAction = PendingAction.SHARE_FEED;
		feedData = params;
		Session session = Session.getActiveSession();
		if(pendingAction.isAllPermissionGranted(session)) {
			handlePendingAction(true, null);
		} else if(!isPenddingPermission) {
			requestPermission(session, pendingAction);
		}
	}
	
	public void getRequestId() {
		pendingAction = PendingAction.GET_REQUEST_ID;
		Session session = Session.getActiveSession();
		if(pendingAction.isAllPermissionGranted(session)) {
			handlePendingAction(true, null);
		} else if(!isPenddingPermission) {
			requestPermission(session, pendingAction);
		}
	}
	
	public void deleteRequestId(String requestId) {
		Request.newDeleteObjectRequest(Session.getActiveSession(), requestId, new Callback() {
			@Override
			public void onCompleted(Response response) {
				FacebookRequestError error = response.getError();
				if(error != null) {
					Log.e(TAG, "deleteRequestId error" + error.toString());
				} else {
					String rawStr = response.getRawResponse();
					Log.d(TAG, "deleteRequestId ret->" + rawStr);
				}
			}
		}).executeAsync();
	}
}

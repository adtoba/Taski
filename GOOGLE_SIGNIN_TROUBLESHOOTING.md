# Google Sign-In Troubleshooting Guide for Android

## Common "Sign In Canceled" Errors on Android

### 1. **Environment Variables Setup**
Make sure you have these in your `.env` file:
```env
ANDROID_CLIENT_ID=your_android_client_id_here
WEB_CLIENT_ID=your_web_client_id_here
IOS_CLIENT_ID=your_ios_client_id_here
```

### 2. **Google Cloud Console Configuration**
- Go to [Google Cloud Console](https://console.cloud.google.com/)
- Select your project
- Go to "APIs & Services" > "Credentials"
- Make sure you have:
  - **Android OAuth 2.0 Client ID** (with your package name)
  - **Web OAuth 2.0 Client ID**
  - **iOS OAuth 2.0 Client ID**

### 3. **Android Package Name**
Ensure your package name in `android/app/build.gradle.kts` matches:
- Google Cloud Console Android client ID
- SHA-1 fingerprint of your signing key

### 4. **SHA-1 Fingerprint**
Get your debug SHA-1:
```bash
cd android
./gradlew signingReport
```

### 5. **Device-Specific Issues**
- **Google Play Services**: Must be updated to latest version
- **Internet Connection**: Device must have stable internet
- **Google Account**: Must be properly set up on device
- **Device Settings**: Check if Google Sign-In is enabled

### 6. **Testing Steps**
1. Clear app data and cache
2. Uninstall and reinstall the app
3. Check Google Play Services version
4. Verify internet connection
5. Try with different Google accounts
6. Check device logs for detailed errors

### 7. **Common Solutions**
- Update Google Play Services
- Clear Google Play Services cache
- Remove and re-add Google account
- Check device date/time settings
- Ensure device is not in battery saver mode

### 8. **Debug Information**
Add this to your auth service for debugging:
```dart
print('Google Sign-In Error: ${e.code}');
print('Error Details: ${e.toString()}');
```

## Quick Fix Checklist
- [ ] Environment variables set correctly
- [ ] Google Cloud Console configured
- [ ] Package name matches
- [ ] SHA-1 fingerprint added
- [ ] Google Play Services updated
- [ ] Internet connection stable
- [ ] Google account properly set up
- [ ] App permissions granted 
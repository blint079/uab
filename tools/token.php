<?php
/**
 * Example of retrieving the products list using Admin account via Magento REST API. OAuth authorization is used
 * Preconditions:
 * 1. Install php oauth extension
 * 2. If you were authorized as a Customer before this step, clear browser cookies for 'yourhost'
 * 3. Create at least one product in Magento
 * 4. Configure resource permissions for Admin REST user for retrieving all product data for Admin
 * 5. Create a Consumer
 */
// $callbackUrl is a path to your file with OAuth authentication example for the Admin user
$callbackUrl = "http://localhost/token.php";
$temporaryCredentialsRequestUrl = "http://aspectsofdecor.com/oauth/initiate?oauth_callback=" . urlencode($callbackUrl);
$adminAuthorizationUrl = 'http://aspectsofdecor.com/admin/oauth_authorize';
$accessTokenRequestUrl = 'http://aspectsofdecor.com/oauth/token';
$apiUrl = 'http://aspectsofdecor.com/api/rest';
$consumerKey = 'd779d257c3a878add0efd8ed96d29781';
$consumerSecret = 'b824a6349c2859f6261e0f1c2f2689d1';

session_start();
if (!isset($_GET['oauth_token']) && isset($_SESSION['state']) && $_SESSION['state'] == 1) {
    $_SESSION['state'] = 0;
}
try {
    $authType = ($_SESSION['state'] == 2) ? OAUTH_AUTH_TYPE_AUTHORIZATION : OAUTH_AUTH_TYPE_URI;
    $oauthClient = new OAuth($consumerKey, $consumerSecret, OAUTH_SIG_METHOD_HMACSHA1, $authType);
    $oauthClient->enableDebug();

    if (!isset($_GET['oauth_token']) && !$_SESSION['state']) {
				echo "trying to get request token<br>";
        $requestToken = $oauthClient->getRequestToken($temporaryCredentialsRequestUrl);
        $_SESSION['secret'] = $requestToken['oauth_token_secret'];
        $_SESSION['state'] = 1;
        header('Location: ' . $adminAuthorizationUrl . '?oauth_token=' . $requestToken['oauth_token']);
        exit;
    } else if ($_SESSION['state'] == 1) {
				echo "got to setToken<br>";
        $oauthClient->setToken($_GET['oauth_token'], $_SESSION['secret']);
        $accessToken = $oauthClient->getAccessToken($accessTokenRequestUrl);
	#raise new Exception $accessToken
        $_SESSION['state'] = 2;
        $_SESSION['token'] = $accessToken['oauth_token'];
        $_SESSION['secret'] = $accessToken['oauth_token_secret'];
        header('Location: ' . $callbackUrl);
        exit;
    } else {
				echo "trying to set token 2<br>";
				echo "this is token and secret<br>";
				print_r ($_SESSION['token']);
				echo "<br>";
				print_r ($_SESSION['secret']);
        $oauthClient->setToken($_SESSION['token'], $_SESSION['secret']);

        $resourceUrl = "$apiUrl/products";
        #$oauthClient->fetch($resourceUrl, array(), 'GET', array('Content-Type' => 'application/json'));
        #$productsList = json_decode($oauthClient->getLastResponse());
        #print_r($productsList);
    }
} catch (OAuthException $e) {
    print_r($e->getMessage());
    echo "<br>THIS IS MY Exception ";
    print_r($e->lastResponse);
}

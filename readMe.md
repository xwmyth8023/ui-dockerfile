# Deploy Environment
## Install Node.js
1. Click this link [node.js](https://nodejs.org/dist/v8.9.4/node-v8.9.4-x64.msi) to download.
3. Click the downloaded package to install, in the third step, select **Add to Path**, then always click next.
4. Check if install successfully by running ```node --version``` on the terminal, if the terminal output like as **vx.x.x**, 
that means Nodejs is installed successfully on your computer; then running ```npm --version```, if the output like **x.x.x**, 
that means npm package manage is installed successfully.

## Install Dependencies
Before install dependencies,you may need to create a folder as your work dir, may be the name is `demo`.
On the terminal, running ```npm install -g nightwatch mocha mochawesome``` on the command line, then **nightwatch** **mocha** **mochawesome** will be installed globally;
if you don't want to use ```-g```, get into your work dir,run```npm init```,then you will see `package.json` file on in your folder; then running ```npm install --save-dev nightwatch mocha mochawesome```,that will be installed on your local dir, you will see detail information on file `package.json`. 
**Note**: the differenc between globally install and local install, please click [this](http://www.cnblogs.com/PeunZhang/p/5629329.html)


## Browser Driver Download
There are links for you to download browser driver, just select the latest version to download.
[Chrome driver](https://chromedriver.storage.googleapis.com/index.html)
[FireFox driver](https://github.com/mozilla/geckodriver/releases)
[Microsoft WebDriver](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/)

## Selenium Server setup
Download **jdk-{VERSION}_windows-x64_bin.exe** file from the [JDK dowloads page](http://www.oracle.com/technetwork/java/javase/downloads/jdk9-downloads-3848520.html),
check this by running ```java -version``` from the command line.
Download the latest version of the **selenium-server-standalone-{VERSION}.jar** file from the [Selenium downloads page](http://selenium-release.storage.googleapis.com/index.html)
and place it on the computer with the browser you want to test. 
Getting into work dir **demo**, create a subfolder named **bin**, put **browser driver** and **selenium server** into it.

If all i wrote above has been completed, continus work is writing test scripts.

# Config Set
## Basic concept
Before writing test scripts, we should set a config file. Go to work dir, maybe there has ben a `nightwatch.json` file, if not, create one, like this.
```json
{
  "src_folders" : ["Tests"],
  "custom_commands_path" : "",
  "custom_assertions_path" : "", 
  "page_objects_path" : "Pages",
  "globals_path" : "",
  "test_runner" : {
    "type": "mocha",
    "options": {
      "retries": 1,
      "reporter": "mochawesome"
       }
    },

  "selenium" : {
    "start_process" : true,
    "server_path":"../demo/bin/selenium-server-standalone-3.4.0.jar",
    "log_path" : "",
    "host" : "127.0.0.1",
    "port" : 4444,
    "cli_args" : {
      "webdriver.chrome.driver" : "bin/chromedriver",
      "webdriver.ie.driver" : "",
      "webdriver.gecko.driver" : "bin/geckodriver"
    }
  },

  "test_settings" : {
    "default" : {
      "launch_url" : "https://qa-www.thebump.com/baby-names",
      "screenshots" : {
        "enabled" : true,
        "path" : "screenshots"
      },
      "desiredCapabilities": {
        "browserName": "chrome",
        "javascriptEnabled": true,
        "acceptSslCerts": true
      }
    },

    "qa" : {
      "launch_url" : "https://qa-www.thebump.com/baby-names",
      "globals": {
        "retryAssertionTimeout": 10000
      },
      "desiredCapabilities": {
        "browserName": "chrome",
        "acceptSslCerts": true
      }
    },
    "production" : {
      "launch_url" : "https://www.thebump.com/baby-names",
      "globals": {
        "retryAssertionTimeout": 10000
      },
      "desiredCapabilities": {
        "browserName": "firefox",
        "acceptSslCerts": true
      }
    },

    "chrome" : {
      "desiredCapabilities": {
        "browserName": "chrome",
        "javascriptEnabled": true,
        "acceptSslCerts": true
      }
    }
  }
}
```

## Test Scripts
Assume that you want to test the function of search for baby names, these steps you will follow:
1. Go to [Baby Name](https://www.thebump.com/baby-names);
2. Input one name(whether it exists) in the search box;
3. Click `search` button
4. Assert the result if is the correct one for your search: if the name exists in the DB, then the result page should show the name; 
if the name doesn't exist in the DB, then the result shouldn't show the name.

Is it right? So based on test steps, our test scripts can be wrote like this on the ```test.js``` file:
```js
module.exports = {
  'Baby Name Search function' : function (browser) {
    browser
      .url('http://www.thebump.com/baby-names') // step 1 input url to go to baby names homepage
      .waitForElementVisible('body', 1000) // wait for element to be visible
      .setValue('input[type=text]', 'tom') // step 2 locate search box, then input name
      .click('button[name=search]') // step 3 locate search button, then click
      .pause(1000)
      .assert.containsText('#main', 'tom') // step 4 assert the result if is the correct one for the search
      .end();
  }
};
```
Now you may found that test scripts are steps we execute test. Yes, exactly right. All test scripts are based on test case. So the important thing is writing good case,
then we can write good scripts.
Now you can running `nightwatch test.js` to execute the script.




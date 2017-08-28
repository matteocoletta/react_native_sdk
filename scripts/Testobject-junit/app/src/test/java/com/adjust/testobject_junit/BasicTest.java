package com.adjust.testobject_junit;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.net.URL;

import io.appium.java_client.AppiumDriver;
import io.appium.java_client.android.AndroidDriver;

public class BasicTest {
    private static final String API_KEY = "76DE22AF894C45C2B522B715E541FCF1";
    private AppiumDriver driver;

    @Before
    public void setUp() throws Exception {

        DesiredCapabilities capabilities = new DesiredCapabilities();

        /* These are the capabilities we must provide to run our test on TestObject */
        capabilities.setCapability("testobject_api_key", API_KEY);
        capabilities.setCapability("testobject_device", "Motorola_Moto_E_2nd_gen_free");

        /* The driver will take care of establishing the connection, so we must provide
        * it with the correct endpoint and the requested capabilities. */
        driver = new AndroidDriver(new URL("http://appium.testobject.com/wd/hub"), capabilities);
    }

    /* We disable the driver after EACH test has been executed. */
    @After
    public void tearDown() {
        driver.quit();
    }

    @Test
    public void testMethod() {
        System.out.println("Testing...");

        //Initial delay
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        while (true) {
            driver.getPageSource();
            String testCondition = driver.findElementByClassName("android.widget.TextView").getText();

            if (!testCondition.equals("I'm here")) {
                System.out.println("Test concluded...");
                break;
            } else {
                System.out.println("still testing...");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

}
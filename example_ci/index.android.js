/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

'use strict';
import React, { Component } from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    ToastAndroid,
    TextInput,
    View,
    NativeEventEmitter,
} from 'react-native';

var ReactNative = require('react-native');
var {
    NativeModules
} = ReactNative;
var module_test = NativeModules.AdjustTest;
import CommandExecutor from './CommandExecutor.js';
import { Adjust, AdjustEvent, AdjustConfig } from 'react-native-adjust';

export default class exampleProject extends Component {
    constructor(props) {
        super(props);
        this.subscription = null;
        this.state = { text: 'Useless Placeholder', i: 1 };
    }

    componentWillMount() {
        //var baseUrl = 'https://10.0.2.2:8443';
        var baseUrl = 'https://jenkins-1.adjust.com:8443';
        Adjust.setTestingMode(baseUrl);
        module_test.setTests("current/Test_Event_Count;current/Test_Event_OrderId;current/Test_Disable_Enable;current/Test_EventBuffering;current/Test_DefaultTracker;current/Test_DelayStart;current/Test_UserAgent;current/Test_SubsessionCount");
        module_test.initTestSession(baseUrl);

        const adjustTestEventReceiver = new NativeEventEmitter(NativeModules.AdjustTest);
        var commandExecutor = new CommandExecutor();
        this.subscription = adjustTestEventReceiver.addListener(
            'command', (json) => {
                var commandDict = JSON.parse(json);
                var className = commandDict['className'];
                var functionName = commandDict['functionName'];
                var params = commandDict['params'];

                //console.log('>>>>>>>>>> className: ' + className);
                //console.log('>>>>>>>>>> functionName: ' + functionName);
                //console.log('>>>>>>>>>> params: ' + params);

                commandExecutor.executeCommand(className, functionName, params);
            });
    }

    componentWillUnmount() {
        this.subscription.remove();
    }

    render() {
        return (
            <View style={styles.container}>
                <Text style={styles.welcome}>
                    I'm here
                </Text>
            </View>
            );
    }
}


const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    }
});

AppRegistry.registerComponent('Example', () => exampleProject);

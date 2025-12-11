try {
    require('react-native-worklets/plugin');
    console.log('Successfully required react-native-worklets/plugin');
} catch (error) {
    console.error('Failed to require react-native-worklets/plugin:', error);
}

trigger HellowWorldTrigger on Account (before insert) {
    System.debug('Hellow World !');
}
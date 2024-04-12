/**
 * @description Test for TranslateService
 *
 * @see TranslateService
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email             | Date                  | JIRA                | Change Summary                             |
 *    |-----------------------------|-----------------------|---------------------|--------------------------------------------|
 *    | ryan.j.a.dela.cruz          | October 24, 2023      | DEPP-5902           | Created file                               |
 */

@isTest
public class TranslateServiceTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        TestDataFactory.generateTestUsers(new List<String>{ 'System_Administrator' });
        Test.stopTest();
    }
    
    @isTest
    static void testGetTranslationEndpoint() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.startTest();
        String translationEndpoint = TranslateService.getTranslationEndpoint();
        Test.stopTest();
        System.assertNotEquals(
            null,
            translationEndpoint,
            'Translation endpoint should not be null.'
        );
        }
    }

    @isTest
    static void testGetDetectionEndpoint() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.startTest();
        String detectionEndpoint = TranslateService.getDetectionEndpoint();
        Test.stopTest();
        System.assertNotEquals(null, detectionEndpoint, 'Detection endpoint should not be null.');
        }
    }

    @isTest
    static void testGetSupportedLanguagesEndpoint() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.startTest();
        String supportedLanguagesEndpoint = TranslateService.getSupportedLanguagesEndpoint();
        Test.stopTest();
        System.assertNotEquals(
            null,
            supportedLanguagesEndpoint,
            'Supported languages endpoint should not be null.'
        );
        }
    }

    @IsTest
    private static void testSingleTranslation() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.setMock(HttpCalloutMock.class, new GoogleTranslationMock(true));

        String translation;
        Test.startTest();
        translation = TranslateService.translateText('test query', 'en');
        Test.stopTest();

        System.assertNotEquals(null, translation, 'Translation should not be null.');
        }
    }

    @IsTest
    private static void testMultipleTranslation() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.setMock(HttpCalloutMock.class, new GoogleTranslationMock(false));

        String[] translations;
        Test.startTest();
        translations = TranslateService.translateTexts(
            new List<String>{ 'test 1', 'test 2' },
            'en'
        );
        Test.stopTest();

        System.assertEquals(2, translations.size(), 'Expected 2 translations.');
        }
    }

    @IsTest
    private static void testSingleTranslationWithSourceLanguage() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.setMock(HttpCalloutMock.class, new GoogleTranslationMock(true));

        String translation;
        Test.startTest();
        translation = TranslateService.translateText('test query', 'en', 'es'); // Translate from English to Spanish
        Test.stopTest();

        System.assertNotEquals(null, translation, 'Translation should not be null.');
        }
    }

    @IsTest
    private static void testMultipleTranslationWithSourceLanguage() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.setMock(HttpCalloutMock.class, new GoogleTranslationMock(false));

        String[] translations;
        Test.startTest();
        translations = TranslateService.translateTexts(
            new List<String>{ 'test 1', 'test 2' },
            'en',
            'fr' // Translate from English to French
        );
        Test.stopTest();

        System.assertEquals(2, translations.size(), 'Expected 2 translations.');
        }
    }

    @IsTest
    private static void testInvalidTranslationCallout() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.setMock(HttpCalloutMock.class, new GoogleTranslationMock(true));

        String translation;
        Test.startTest();
        translation = TranslateService.translateText(null, 'en');
        Test.stopTest();

        System.assertEquals(null, translation, 'Translation of a null query should be null.');
        }
    }

    @IsTest
    private static void testSingleDetection() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.setMock(HttpCalloutMock.class, new GoogleDetectionMock());

        String detections;
        Test.startTest();
        detections = TranslateService.detectLanguage('test query');
        Test.stopTest();

        System.assertNotEquals(null, detections, 'Detection should not be null.');
        }
    }

    @IsTest
    private static void testMultipleDetections() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.setMock(HttpCalloutMock.class, new GoogleDetectionMock());

        String[] detections;
        Test.startTest();
        detections = TranslateService.detectLanguages(new List<String>{ 'test 1', 'test 2' });
        Test.stopTest();

        System.assertNotEquals(null, detections, 'Detections should not be null.');
        System.assertEquals(2, detections.size(), 'Expected 2 detections.');
        }
    }

    @IsTest
    private static void testInvalidDetectionCallout() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.setMock(HttpCalloutMock.class, new GoogleDetectionMock());

        String detections;
        Test.startTest();
        detections = TranslateService.detectLanguage(null);
        Test.stopTest();

        System.assertEquals(null, detections, 'Detection of a null query should be null.');
        }
    }

    @isTest
    static void testGetSupportedLanguages() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        Test.setMock(HttpCalloutMock.class, new GoogleSupportedLanguagesMock());

        String supportedLanguages = TranslateService.getSupportedLanguages();
        System.assertNotEquals(null, supportedLanguages, 'Supported languages should not be null.');
        }
    }

    @isTest
    static void testMapLanguageCode() {
        System.runAs(TestDataFactory.getSystemAdminUser()){
        // Test mapping for 'iw' (Hebrew)
        String mappedHebrew = TranslateService.mapLanguageCode('iw');
        System.assertEquals('he', mappedHebrew, 'Hebrew should be mapped to "he"');

        // Test mapping for 'zh' (Chinese Simplified)
        String mappedChinese = TranslateService.mapLanguageCode('zh');
        System.assertEquals('zh-CN', mappedChinese, 'Chinese should be mapped to "zh-CN"');

        // Test mapping for 'fil' (Filipino)
        String mappedFilipino = TranslateService.mapLanguageCode('fil');
        System.assertEquals('tl', mappedFilipino, 'Filipino should be mapped to "tl"');

        // Test mapping for 'jw' (Javanese)
        String mappedJavanese = TranslateService.mapLanguageCode('jw');
        System.assertEquals('jv', mappedJavanese, 'Javanese should be mapped to "jv"');

        // Test a language code with no mapping
        String unmappedCode = TranslateService.mapLanguageCode('xx');
        System.assertEquals('xx', unmappedCode, 'Unmapped code should remain unchanged');
        }
    }

    public class GoogleTranslationMock implements HttpCalloutMock {
        private Boolean isSingleTranslation;

        // Constructor to specify whether it's a single or multiple translation
        public GoogleTranslationMock(Boolean isSingleTranslation) {
            this.isSingleTranslation = isSingleTranslation;
        }

        // Implementation of the HttpCalloutMock interface
        public HTTPResponse respond(HTTPRequest req) {
            // Assert that the request endpoint and method are as expected
            System.assert(req.getEndpoint().contains(TranslateService.getTranslationEndpoint()));
            System.assertEquals('POST', req.getMethod());

            // Return the appropriate response based on the translation type
            if (this.isSingleTranslation) {
                return prepareSingleTranslationResponse();
            } else {
                return prepareMultipleTranslationResponse();
            }
        }

        // Prepare a mock HTTP response for a single translation
        private HttpResponse prepareSingleTranslationResponse() {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{"data":{"translations":[{"translatedText":"Der schnelle braune Fuchs sprang über den faulen Hund."}]}}'
            );
            res.setStatusCode(200);
            return res;
        }

        // Prepare a mock HTTP response for multiple translations
        private HttpResponse prepareMultipleTranslationResponse() {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{"data":{"translations":[' +
                    '{"translatedText":"Der schnelle braune Fuchs sprang über den faulen Hund.",' +
                    '"detectedSourceLanguage":"en"},' +
                    '{"translatedText":"Sie weiß, was sie weiß, aber ich weiß nicht, was ich früher wusste.",' +
                    '"detectedSourceLanguage":"en"}]}}'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    public class GoogleDetectionMock implements HttpCalloutMock {
        // Implementation of the HttpCalloutMock interface
        public HTTPResponse respond(HTTPRequest req) {
            // Assert that the request endpoint and method are as expected
            System.assert(req.getEndpoint().contains(TranslateService.getDetectionEndpoint()));
            System.assertEquals('POST', req.getMethod());

            // Create a mock HTTP response for language detection
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{"data":{"detections":[' +
                    '[{"confidence":0.2132132132131234,"isReliable":false,"language":"en"}],' +
                    '[{"confidence":0.2425314223231244,"isReliable":false,"language":"en"}]]}}'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    public class GoogleSupportedLanguagesMock implements HttpCalloutMock {
        // Implementation of the HttpCalloutMock interface
        public HTTPResponse respond(HTTPRequest req) {
            // Assert that the request endpoint and method are as expected
            System.assert(
                req.getEndpoint().contains(TranslateService.getSupportedLanguagesEndpoint())
            );
            System.assertEquals('POST', req.getMethod());

            // Create a mock HTTP response for supported languages
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{"data":{"languages":[' +
                    '{"language":"en","name":"English"},' +
                    '{"language":"es","name":"Spanish"},' +
                    '{"language":"fr","name":"French"}' +
                    ']}}'
            );
            res.setStatusCode(200);
            return res;
        }
    }
}

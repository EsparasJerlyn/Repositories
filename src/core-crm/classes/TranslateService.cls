/**
 * @description A Salesforce Apex class for interacting with the Google Translate API,
 * enabling translation and language detection of text content. This class
 * offers methods to facilitate translation from one language to another and
 * language detection for a wide range of use cases. It provides a convenient
 * way to integrate translation and language detection services into Salesforce
 * applications while abstracting the underlying API calls and complexity.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email             | Date                  | JIRA                | Change Summary                             |
 *    |-----------------------------|-----------------------|---------------------|--------------------------------------------|
 *    | ryan.j.a.dela.cruz          | October 17, 2023      | DEPP-5902           | Created file                               |
 */

public with sharing class TranslateService {
    /** API CONSTANTS **/
    private static final String DETECTION_ENDPOINT = System.Label.GoogleDetectionEndpoint;
    private static final String TRANSLATION_ENDPOINT = System.Label.GoogleTranslationEndpoint;
    private static final String SUPPORTED_LANGUAGES_ENDPOINT = System.Label.GoogleSupportedLanguagesEndpoint;

    /** Map to store language code mappings **/
    private static final Map<String, String> LANGUAGE_CODE_MAPPING = new Map<String, String>{
        'iw' => 'he',       // Map "iw" (Hebrew) to "he" (Hebrew)
        'zh' => 'zh-CN',    // Map "zh" (Chinese Simplified) to "zh-CN" (Chinese Simplified Mainland China)
        'fil' => 'tl',      // Map "fil" (Filipino) to "tl" (Filipino Tagalog)
        'jw' => 'jv'        // Map "jw" (Javanese) to 'jv' (Javanese)
    };

    /** GETTERS **/
    /**
     * Get the translation endpoint.
     *
     * @return The translation endpoint URL.
     */
    public static String getTranslationEndpoint() {
        return TRANSLATION_ENDPOINT;
    }

    /**
     * Get the detection endpoint.
     *
     * @return The detection endpoint URL.
     */
    public static String getDetectionEndpoint() {
        return DETECTION_ENDPOINT;
    }

    /**
     * Get the supported languages endpoint.
     *
     * @return The supported languages endpoint URL.
     */
    public static String getSupportedLanguagesEndpoint() {
        return SUPPORTED_LANGUAGES_ENDPOINT;
    }

    /** TRANSLATION API METHODS **/
    /**
     * Translate an array of texts from a source language to a target language.
     *
     * @param queries An array of texts to be translated.
     * @param source  The source language (optional).
     * @param target  The target language.
     * @return An array of translated texts.
     */
    public static String[] translateTexts(String[] queries, String source, String target) {
        try {
            // Build the JSON we will send to the API.
            String body = buildJSONBody(queries, source, target, 'text');

            // Get the API response JSON.
            String responseBody = apiCallout(body, getTranslationEndpoint(), 'POST').getBody();

            // Parse the response to get the required information.
            TranslationModel model = (TranslationModel) JSON.deserialize(
                responseBody,
                TranslationModel.class
            );

            // Get the translated texts from the model.
            String[] translations = new List<String>{};
            for (Translation translation : model.data.translations) {
                translations.add(translation.translatedText);
            }
            return translations;
        } catch (Exception e) {
            Logger.error(
                    'Exception caught in method translateTexts in Apex class TranslateService.'
                )
                .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
        return null;
    }

    /**
     * Translate an array of texts to a target language.
     *
     * @param queries An array of texts to be translated.
     * @param target  The target language.
     * @return An array of translated texts.
     */
    public static String[] translateTexts(String[] queries, String target) {
        return translateTexts(queries, null, target);
    }

    /**
     * Translate a text from a source language to a target language.
     *
     * @param query  The text to be translated.
     * @param source The source language (optional).
     * @param target The target language.
     * @return The translated text.
     */
    @AuraEnabled(cacheable=false)
    public static String translateText(String query, String source, String target) {
        String[] translations = translateTexts(new List<String>{ query }, source, target);
        return translations != null && !translations.isEmpty() ? translations[0] : null;
    }

    /**
     * Translate a text to a target language.
     *
     * @param query  The text to be translated.
     * @param target The target language.
     * @return The translated text.
     */
    public static String translateText(String query, String target) {
        return translateText(query, null, target);
    }

    /**
     * Get the supported languages for translation.
     *
     * @return A map of language codes to language names.
     */
    @AuraEnabled(cacheable=true)
    public static String getSupportedLanguages() {
        try {
            Map<String, String> supportedLanguages = new Map<String, String>();
            String target = 'en';
            // Build the JSON we will send to the API.
            String body = buildJSONBody(null, null, target, null);

            // Send a GET request to the supported languages endpoint
            String responseBody = apiCallout(body, getSupportedLanguagesEndpoint(), 'POST')
                .getBody();

            // Parse the response to get the supported languages
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(
                responseBody
            );

            // The "languages" data is nested within the "data" key
            Map<String, Object> data = (Map<String, Object>) jsonResponse.get('data');

            // Extract language code and name and add to the map
            List<Object> languages = (List<Object>) data.get('languages');
            for (Object lang : languages) {
                Map<String, Object> languageInfo = (Map<String, Object>) lang;
                supportedLanguages.put(
                    (String) languageInfo.get('language'),
                    (String) languageInfo.get('name')
                );
            }

            // Serialize the map to JSON
            return JSON.serialize(supportedLanguages);
        } catch (Exception e) {
            Logger.error(
                    'Exception caught in method getSupportedLanguages in Apex class TranslateService.'
                )
                .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
        return null;
    }

    private static String buildJSONBody(
        String[] queries,
        String source,
        String target,
        String format
    ) {
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        if (queries != null) {
            for (String query : queries) {
                gen.writeStringField('q', query);
            }
        }
        if (source != null) {
            gen.writeStringField('source', source);
        }
        if (target != null) {
            gen.writeStringField('target', target);
        }
        if (format != null) {
            gen.writeStringField('format', format);
        }
        gen.writeEndObject();

        return gen.getAsString();
    }

    /** DETECTION API METHODS **/
    /**
     * Detect the languages of an array of texts.
     *
     * @param queries An array of texts to detect languages.
     * @return An array of detected languages.
     */
    public static String[] detectLanguages(String[] queries) {
        try {
            // Build the JSON we will send to the API.
            String body = buildJSONBody(queries, null, null, null);

            // Get the API response JSON.
            String responseBody = apiCallout(body, getDetectionEndpoint(), 'POST').getBody();

            DetectionModel model = (DetectionModel) JSON.deserialize(
                responseBody,
                DetectionModel.class
            );

            String[] detections = new List<String>{};
            for (Detection[] detectionsList : model.data.detections) {
                String detectedLanguage = detectionsList.get(0).language;
                String mappedLanguage = mapLanguageCode(detectedLanguage);
                detections.add(mappedLanguage);
            }

            return detections; // TODO: Take into account the confidence?
        } catch (Exception e) {
            Logger.error(
                    'Exception caught in method detectLanguages in Apex class TranslateService.'
                )
                .setExceptionDetails(e);
        } finally {
            if (Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
        return null;
    }

    /**
     * Detect the language of a text.
     *
     * @param query The text to detect its language.
     * @return The detected language.
     */
    @AuraEnabled(cacheable=false)
    public static String detectLanguage(String query) {
        String[] detections = detectLanguages(new List<String>{ query });
        return detections != null && !detections.isEmpty() ? detections[0] : null;
    }

    /**
     * Map language codes to ensure consistency.
     *
     * @param languageCode The language code to map.
     * @return The mapped language code.
     */
    public static String mapLanguageCode(String languageCode) {
        // Check if the language code is in the map
        if (LANGUAGE_CODE_MAPPING.containsKey(languageCode)) {
            // If found in the map, return the mapped value
            return LANGUAGE_CODE_MAPPING.get(languageCode);
        } else {
            // If not found, return the input language code
            return languageCode;
        }
    }

    /** CALLOUT HELPER METHOD **/
    /**
     * Make a callout to an API endpoint.
     *
     * @param body     The request body (null for GET requests).
     * @param endpoint The API endpoint.
     * @param method   The HTTP method (GET or POST).
     * @return The API response.
     */
    private static HttpResponse apiCallout(String body, String endpoint, String method) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:GOOGLE' + endpoint);
        request.setMethod(method);

        if (body != null) {
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
        }

        HttpResponse response = http.send(request);
        return response;
    }

    /** MODELS TO PARSE API JSONS **/
    private class TranslationModel {
        public Data data;
    }

    private class Translation {
        public String translatedText;
        public String detectedSourceLanguage;
    }

    private class DetectionModel {
        public Data data;
    }

    private class Data {
        public List<List<Detection>> detections;
        public Translation[] translations;
    }

    private class Detection {
        public String language;
        public Boolean isReliable;
        public Decimal confidence;
    }
}
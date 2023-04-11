package com.example;

import com.amazonaws.serverless.exceptions.ContainerInitializationException;
import com.amazonaws.serverless.proxy.internal.testutils.MockLambdaContext;
import com.amazonaws.serverless.proxy.model.AwsProxyRequest;
import com.amazonaws.serverless.proxy.model.AwsProxyResponse;
import com.amazonaws.serverless.proxy.model.MultiValuedTreeMap;
import com.amazonaws.services.lambda.runtime.Context;
import io.micronaut.function.aws.proxy.MicronautLambdaHandler;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class HomeControllerTest {

    private static MicronautLambdaHandler handler;
    private static Context lambdaContext = new MockLambdaContext();

    @BeforeAll
    public static void setupSpec() {
        try {
            handler = new MicronautLambdaHandler();
        } catch (ContainerInitializationException e) {
            e.printStackTrace();
        }
    }

    @AfterAll
    public static void cleanupSpec() {
        handler.getApplicationContext().close();
    }

    @Test
    void testHandlerGet() {
        AwsProxyRequest request = new AwsProxyRequest();
        request.setHttpMethod("GET");
        request.setPath("/hello");
        AwsProxyResponse response = handler.handleRequest(request, lambdaContext);
        assertEquals(200, response.getStatusCode());
        assertEquals("{\"message\":\"Hello ?\"}", response.getBody());
    }

    @Test
    void testHandlerGetWithParam() {
        MultiValuedTreeMap<String, String> queryParams = new MultiValuedTreeMap<>();
        queryParams.add("name", "foo");

        AwsProxyRequest request = new AwsProxyRequest();
        request.setHttpMethod("GET");
        request.setPath("/hello");
        request.setMultiValueQueryStringParameters(queryParams);
        AwsProxyResponse response = handler.handleRequest(request, lambdaContext);
        assertEquals(200, response.getStatusCode());
        assertEquals("{\"message\":\"Hello foo\"}", response.getBody());
    }

    @Test
    void testHandlerPost() {
        AwsProxyRequest request = new AwsProxyRequest();
        request.setHttpMethod("POST");
        request.setPath("/hello");
        request.setBody("""
                {
                  "name": "foo"
                }
                """);
        AwsProxyResponse response = handler.handleRequest(request, lambdaContext);
        assertEquals(200, response.getStatusCode());
        assertEquals("{\"message\":\"Hello foo\"}", response.getBody());
    }
}

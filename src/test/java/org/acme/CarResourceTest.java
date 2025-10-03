package org.acme;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;

@QuarkusTest
public class CarResourceTest {

    @Test
    public void testListCarsEndpoint() {
        given()
          .when().get("/car")
          .then()
             .statusCode(200)
             .body("", hasSize(2));
    }

    @Test
    public void testGetCarEndpoint() {
        given()
          .when().get("/car/1")
          .then()
             .statusCode(200)
             .body("brand", is("Tesla"))
             .body("model", is("Model 3"));
    }

    @Test
    public void testCreateCarEndpoint() {
        given()
          .contentType("application/json")
          .body("{\"brand\":\"Audi\",\"model\":\"e-tron\"}")
          .when().post("/car")
          .then()
             .statusCode(201)
             .body("brand", is("Audi"))
             .body("model", is("e-tron"));
    }
}

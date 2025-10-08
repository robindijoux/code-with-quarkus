package org.acme;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;

@Path("/car")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CarResource {

    // Database simulation
    private static List<Car> cars = new ArrayList<>();
    
    static {
        cars.add(new Car(1L, "Tesla", "Model 3"));
        cars.add(new Car(2L, "BMW", "i4"));
    }

    @GET
    public List<Car> list() {
        return cars;
    }

    @GET
    @Path("/{id}")
    public Car get(@PathParam("id") Long id) {
        return cars.stream()
            .filter(c -> c.id.equals(id))
            .findFirst()
            .orElseThrow(() -> new NotFoundException("Car not found"));
    }

    @POST
    public Response create(Car car) {
        car.id = (long) (cars.size() + 1);
        cars.add(car);
        return Response.status(201).entity(car).build();
    }

    @PUT
    @Path("/{id}")
    public Car update(@PathParam("id") Long id, Car updatedCar) {
        Car car = get(id);
        car.brand = updatedCar.brand;
        car.model = updatedCar.model;
        return car;
    }

    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") Long id) {
        cars.removeIf(c -> c.id.equals(id));
        return Response.noContent().build();
    }

    public static class Car {
        public Long id;
        public String brand;
        public String model;

        public Car() {}
        
        public Car(Long id, String brand, String model) {
            this.id = id;
            this.brand = brand;
            this.model = model;
        }
    }
}

# cs462Flowers
CS462 Final Project - Flower Delivery

Christopher Ward
Cameron Hymas
Chad Barlow

Final Project Proposal

What it will do:

We will be implementing an altered version of the Flower Delivery system. We hope to be able to make some significant changes to the system from the suggested design, based off Christopher’s real world flower delivery experience. We will begin with the default behaviors detailed at https://github.com/windley/CS462-Event-Edition/blob/master/project-2013/Lab3.md. Rather than using FourSquare to track the drivers, we plan to use the Google Maps API for both route planning and driver location. Assuming we complete this functionality in time, we will extend the functionality with some of Christopher’s more realistic features. </br>
The original system has some glaring inefficiencies, most especially when it comes to multiple deliveries in a similar area. While the original system implies that deliveries are bid upon and taken one at a time, we want to build a system that can take a cluster of deliveries as a single biddable event, and perhaps even chain deliveries from multiple different shops. This way we could theoretically increase the efficiency and capability of the drivers while also lowering delivery times for customers. We recognize this is equivalent to the traveling salesman problem, so only minor, reasonable improvements will be used.

Event architecture:

•	rfq:delivery_ready - a flower shop has a delivery or delivery cluster ready to be picked up for delivery.</br>
•	rfq:bid_available - a driver has signaled that they are willing and able to take a delivery.</br>
•	*post:delivery_made - a driver has successfully delivered an order, which is useful for the flower shop to know about, both for their own records and in case the person who ordered the flowers (rarely the person who received them) calls to ask about the order status.</br>
•	*post:delivery_issue - a driver is reporting an issue with a delivery, such as an “Unable to deliver” message if the recipient wasn’t at home, or a “Problem with order” message if either there was a mistake with the order, or something has happened (like vases breaking) to make the product undeliverable, meaning that the shop needs to be ready to respond appropriately.</br>

Items marked with a * are concepts we may implement, rather than parts of the core product.

APIs used:

•	Twilio for SMS messages to the drivers about new deliveries or delivery clusters.</br>
•	Google Maps for optimizing routes, grouping delivery clusters, and perhaps for drivers to report location.

Work plan:

Chris will initially focus on things from the flower shop angle, including the Twilio messages, and Cameron will focus on the driver interactions, including working with the Google Maps API. Chad will work on the front-end clients and connectors. We will continue to shift and reevaluate responsibilities as they become evident from working on the project.

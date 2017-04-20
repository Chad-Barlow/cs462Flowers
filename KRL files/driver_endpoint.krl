ruleset delivery_service_endpoint {
  meta {
    name "delivery_service_endpoint"
    description << A ruleset that serves as the endpoint for the delivery service in the flower delivery system >>
    author "Chris Ward"
    shares __testing
  }

  global {
    __testing = { "events": [ { "domain": "rfq", "type": "delivery_ready",
                                "attrs": ["shopID", "dest"] } ]
                }
  }

  rule delivery_ready {
    select when rfq delivery_ready
    pre {
      shopID = event:attr("shopID")
      dest = event:attr("dest")

      formMap = { "from": "+14844645854", "To": "+18013691234", "Body": "stuff goes here" }
    }
    send_directive("distributing") with 
      shop = shopID
      dest = dest

    http:post("https://api.twilio.com/2010-04-01/Accounts/AC8f153df954435bff1ac980a2cca4bce2/Messages.json")
      with body = "A delivery is ready..." 
        and form = formMap
        and headers = {"content-type": "application/x-www-form-urlencoded"};
  }

  rule auto_accept {
    select when wrangler inbound_pending_subscription_added
    pre {
      attributes = event:attrs().klog("subcription:")
    }
    always {
      raise wrangler event "pending_subscription_approval"
        attributes attributes
    }
  }
}
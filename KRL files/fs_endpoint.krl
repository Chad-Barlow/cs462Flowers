ruleset flower_shop_endpoint {
  meta {
    name "flower_shop_endpoint"
    description << A ruleset that serves as the endpoint for flower shops to talk to in the flower delivery system >>
    author "Chris Ward"
    shares __testing
  }

  global {
    __testing = { "events": [ { "domain": "delivery", "type": "ready",
                                "attrs": ["shopID", "dest"] },
                              { "domain": "rfq", "type": "bid_available",
                                "attrs": ["shopID", "driverID"] } ] 
    }
  }

  rule report_delivery_ready {
    select when delivery ready
    pre {
      shopID = event:attr("shopID")
      dest = event:attr("dest")
    }
    send_directive("ready") with
      shop = shopID
      dest = dest
    always {
      raise rfq event "delivery_ready"
        attributes { "shopID": shopID, "dest": dest }
    }
  }
}
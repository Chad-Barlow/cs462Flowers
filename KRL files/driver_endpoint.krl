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
    }
    send_directive("distributing") with 
      shop = shopID
      dest = dest
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
ruleset driverReg {
    meta {
        name "Driver registration helper"
        description <<
            Collect driver personal information and information about the flower shops
            for whom the driver delivers. Also provide a UI for this data that can be used
            by a "driver" once he installs it to his Kynetx account.
            
            Used for CS 462 Lab 3 in Winter 2012.
        >>
        author "Steve Nay"
        logging off
        
        // Functions this module provides:
        provides get_driver_name, get_driver_phone, get_flower_shops
        
        // Use the following line in your meta block to import this module:
        // use module a163x154 as driver_data
    }

    dispatch {
        domain "exampley.com"
    }

    global {
        ///////////////////////////////////////////////
        // Module functions
        
        // Return the driver name as a string
        get_driver_name = function() {
            ent:driver_name;
        };
        
        // Return the driver phone number as a string
        get_driver_phone = function() {
            ent:driver_phone;
        };
        
        // Return the flower shops as an array of string-encoded hashes
        get_flower_shops = function() {
            ent:flower_shops;
        };

        title = "Driver Registration Helper";
    }
    
    ///////////////////////////////////////////////
    // Rules to handle the data
    
    // Save driver name and/or phone number.
    rule save_driver_name {
        select when pds new_driver_data_available
        pre {
            driver_name = event:param("driver_name") || ent:driver_name;
            driver_phone = event:param("driver_phone") || ent:driver_phone;
        }
        noop();
        always {
            set ent:driver_name driver_name;
            set ent:driver_phone driver_phone;
            raise pds event driver_data_updated;
        }
    }
    
    // Add a new shop to the array. Must already be string-encoded.
    rule save_new_shop {
        select when pds new_shop_available
        pre {
            shop_encoded = event:param("shop");
            shop_array = ["#{shop_encoded}"];
            new_array = ent:flower_shops.typeof().match(re/array/gi) => shop_array.union(ent:flower_shops) | shop_array;
        }
        noop();
        always {
            set ent:flower_shops new_array;
            raise pds event new_shop_added;
        }
    }
    
    // Clear the shops list. Useful for debugging.
    rule reset_shops {
        select when pds shop_list_invalid
        noop();
        always {
            set ent:flower_shops [];
            raise pds event shop_list_empty;
        }
    }
    
    
    ///////////////////////////////////////////////
    // Rules to handle the UI
    
    // Show the main menu
    rule menu {
        select when pageview ".*" setting ()
        pre {
            msg = <<
                What would you like to do? <br />
                <input type="button" id="driver" value="Update my information" /><br />
                <input type="button" id="shop" value="Add a flower shop's information" /><br />
                <input type="button" id="show_shops" value="Display all my shops" /><br />
            >>;
        }
        {
            notify(title, msg) with sticky=true;
            watch("#driver", "click");
            watch("#shop", "click");
            watch("#show_shops", "click");
        }
    }
    
    // Update driver info
    rule driver_info {
        select when web click "#driver"
        pre {
            driver_name = get_driver_name();
            driver_phone = get_driver_phone();
            msg = <<
                Update driver info
                <hr />
                <form id="driver-form">
                    Your name: <input type="text" name="driver-name" value="#{driver_name}" /><br />
                    Your phone number: <input type="text" name="driver-phone" value="#{driver_phone}" /><br />
                    <input type="submit" value="Update" />
                </form>
                    
            >>;
        }
        {
            notify(title, msg) with sticky=true;
            watch("#driver-form", "submit");
        }
    }
    
    rule driver_info_submit {
        select when web submit "driver-form"
        noop();
        always {
            raise pds event new_driver_data_available with
                driver_name=event:param("driver-name") and 
                driver_phone=event:param("driver-phone");
        }
    }
    
    rule driver_info_updated {
        select when pds driver_data_updated
        pre {
            driver_name = get_driver_name();
            driver_phone = get_driver_phone();
            msg = <<
                Okay. I updated your name to #{driver_name} and your phone number to #{driver_phone};
            >>;
        }
        notify(title, msg);
    }
    
    // Add a new shop
    rule shop_info {
        select when web click "#shop"
        pre {
            msg = <<
                Add a new flower shop
                <hr />
                <form id="shop-form">
                    Name: <input type="text" name="shop-name" /><br />
                    ESL: <input type="text" name="shop-esl" /><br />
                    Latitude: <input type="text" name="shop-lat" /><br />
                    Longitude: <input type="text" name="shop-lng" /><br />
                    <input type="submit" />
                </form>
            >>;
        }
        {
            notify(title, msg) with sticky=true;
            watch("#shop-form", "submit");
        }
    }
    
    rule shop_info_submit {
        select when web submit "shop-form"
        pre {
            shop_name = event:param("shop-name");
            shop_esl = event:param("shop-esl");
            shop_lat = event:param("shop-lat");
            shop_lng = event:param("shop-lng");
            shop = {"name": shop_name,
                "esl": shop_esl,
                "lat": shop_lat,
                "lng": shop_lng};
            shop_encoded = shop.encode();
        }
        noop();
        always {
            raise pds event new_shop_available with
                shop=shop_encoded;
        }
    }
    
    // Show existing shops
    rule show_shops {
        select when web click "show_shops" or pds new_shop_added
        pre {
            msg = <<
                Current shops (<a href="#" id="clear_shops">clear</a>):<hr />
                <div id="items"></div>
                
            >>;
        }
        {
            notify(title, msg) with sticky=true;
            watch("#clear_shops", "click");
        }
        fired {
            raise explicit event shop_list_ui_ready;
        }
    }
    
    rule populate_shops {
        select when explicit shop_list_ui_ready
        foreach get_flower_shops() setting (item)
        pre {
            shop = item.decode();
            shop_name = shop.pick("name");
            shop_esl = shop.pick("esl");
            shop_lat = shop.pick("lat");
            shop_lng = shop.pick("lng");
            msg = <<
                #{shop_name}, at (#{shop_lat}, #{shop_lng}). ESL: #{shop_esl}<br /><br />
            >>;
        }
        append("#items", msg);
    }
    
    rule clear_shops {
        select when web click "clear_shops"
        noop();
        fired {
            raise pds event shop_list_invalid;
        }
    }
    
    rule shops_cleared {
        select when pds shop_list_empty
        notify(title, "Cleared out the list of shops.");
    }
}
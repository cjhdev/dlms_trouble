# Copyright (c) 2016 Cameron Harper
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#  
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "test/unit"
require 'dlms_trouble/access_request'

class TestAccessRequest < Test::Unit::TestCase

    include DLMSTrouble

    def test_init_defaults

        ar = AccessRequest.new

        assert_equal(true, ar.confirmed?)
        assert_equal(false, ar.breakOnError?)
        assert_equal(false, ar.selfDescribe?)
        assert_equal(false, ar.highPriority?)
        assert_equal(nil, ar.getTimeStamp)
        assert_equal(0, ar.getInvokeID)
        
    end

    def test_init_block

        theTime = Time.now

        ar = AccessRequest.new do
            confirmed(false)
            breakOnError(true)
            selfDescribe(true)
            highPriority(true)
            timeStamp(theTime)
            invokeID(42)

        end

        assert_equal(false, ar.confirmed?)
        assert_equal(true, ar.breakOnError?)
        assert_equal(true, ar.selfDescribe?)
        assert_equal(true, ar.highPriority?)
        assert_equal(theTime, ar.getTimeStamp)
        assert_equal(42, ar.getInvokeID)
    
    end

    def test_init_functional

        theTime = Time.now

        ar = AccessRequest.new.confirmed(false).breakOnError(true).selfDescribe(true).highPriority(true).timeStamp(theTime).invokeID(42)
            
        assert_equal(false, ar.confirmed?)
        assert_equal(true, ar.breakOnError?)
        assert_equal(true, ar.selfDescribe?)
        assert_equal(true, ar.highPriority?)
        assert_equal(theTime, ar.getTimeStamp)
        assert_equal(42, ar.getInvokeID)
    
    end

    def test_to_axdr_noRequests

        assert_equal("\xd9\x40\x00\x00\x00\x00\x00\x00".force_encoding("ASCII-8BIT"), AccessRequest.new.to_axdr)
   
    end

end

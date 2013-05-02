require 'spec_helper'

describe Wasabi::Parser do

  it 'knows xs:all types' do
    parser = parse('
      <xs:complexType name="MpUser">
        <xs:all>
          <xs:element name="avatar_thumb_url" type="xs:string"/>
          <xs:element name="speciality" type="xs:string"/>
          <xs:element name="avatar_icon_url" type="xs:string"/>
          <xs:element name="firstname" type="xs:string"/>
          <xs:element name="city" type="xs:string"/>
          <xs:element name="mp_id" type="xs:int"/>
          <xs:element name="lastname" type="xs:string"/>
          <xs:element name="login" type="xs:string"/>
        </xs:all>
      </xs:complexType>
    ')

    expect(parser.complex_types).to include('MpUser')
    mp_user = parser.complex_types['MpUser']

    expect(mp_user).to be_a(Wasabi::Type)
    expect(mp_user).to have(8).children

    expect(mp_user.children).to include(
      { :name => 'mp_id',     :type => 'xs:int',    :simple_type => true, :qualified => false, :singular => true },
      { :name => 'firstname', :type => 'xs:string', :simple_type => true, :qualified => false, :singular => true },
      { :name => 'lastname',  :type => 'xs:string', :simple_type => true, :qualified => false, :singular => true },
      { :name => 'login',     :type => 'xs:string', :simple_type => true, :qualified => false, :singular => true }
    )
  end

  it 'determines whether elements are simple types by their namespace' do
    parser = parse('
      <xs:element name="TermOfPayment">
        <xs:complexType>
          <xs:sequence>
            <xs:element minOccurs="0" maxOccurs="1" name="termOfPaymentHandle" type="tns:TermOfPaymentHandle" />
            <xs:element minOccurs="1" maxOccurs="1" name="value" nillable="true" type="xs:decimal" />
          </xs:sequence>
        </xs:complexType>
      </xs:element>
    ')

    expect(parser.elements).to include('TermOfPayment')
    terms = parser.elements['TermOfPayment']

    expect(terms).to be_a(Wasabi::Type)
    expect(terms).to have(2).children

    expect(terms.children).to eq([
      {
        :name        => 'termOfPaymentHandle',
        :type        => 'tns:TermOfPaymentHandle',
        :simple_type => false,
        :qualified   => false,
        :singular    => true
      },
      {
        :name        => 'value',
        :type        => 'xs:decimal',
        :simple_type => true,
        :qualified   => false,
        :singular    => true
      }
    ])
  end

  def parse(types)
    wsdl = %'<definitions name="Api" targetNamespace="urn:ActionWebService"
                 xmlns="http://schemas.xmlsoap.org/wsdl/"
                 xmlns:tns="urn:ActionWebService"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema">
               <types>
                 <xs:schema xmlns="http://www.w3.org/2001/XMLSchema" targetNamespace="urn:ActionWebService">
                   #{types}
                 </xs:schema>
               </types>
             </definitions>'

    parser = Wasabi::Parser.new Nokogiri.XML(wsdl)
    parser.parse
    parser
  end

end

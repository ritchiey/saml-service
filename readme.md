# SAML Service

AAF service responsible for SAML data storage, metadata generation and inter-federation metadata processing.

## Production Concerns

### eduGAIN

#### Exporting an AAF registered IdP

To export an AAF registered IdP to eduGAIN:

1. Get a session on `app4.core.aaf.edu.au` 
1. Become the `saml` user, `$> sudo -iu saml`
1. Source `.app-env`
1. Change to `repository`
1. Run `rails c`
1. Run the following in the console line by line (there might be Sequel gem warnings, these can be ignored):

```ruby
entity_id = 'https://example.edu.au/idp/shibboleth'

ed = EntityId[uri: entity_id].entity_descriptor
ea = ed.entity_attribute || MDATTR::EntityAttribute.create(entity_descriptor: ed)

# IdP R&S
a = Attribute.create name: 'http://macedir.org/entity-category-support', entity_attribute: ea
nf = NameFormat.create attribute: a, uri: 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
av = AttributeValue.create value: 'http://refeds.org/category/research-and-scholarship', attribute: a

# SIRTFI
a = Attribute.create name: 'urn:oasis:names:tc:SAML:attribute:assurance-certification', entity_attribute: ea
nf = NameFormat.create attribute: a, uri: 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
av = AttributeValue.create value: 'https://refeds.org/sirtfi', attribute: a


# Export to eduGAIN
ed.known_entity.tag_as('aaf-edugain-export')


# Finalize
ed.save
ed.known_entity.touch
```

Validate the EntityID will now be pushlished to the global feed:

$> http https://saml.aaf.edu.au/mdq/aaf-edugain-export/entities Accept:application/samlmetadata+xml | rg 'https://idp.example.edu.au/idp/shibboelth'

Advise support all is complete. On our next Metadata publish this will be pushed out to S3 and will picked up and pushed out by global
metadata aggregate in around 24 hours. Check https://technical.edugain.org/entities to ensure it shows up after those 24 hours if necessary.

#### Exporting an AAF registered SP

To export an AAF registered SP to eduGAIN:

1. Get a session on `app4.core.aaf.edu.au` 
1. Become the `saml` user, `$> sudo -iu saml`
1. Source `.app-env`
1. Change to `repository`
1. Run `rails c`
1. Run the following in the console line by line (there might be Sequel gem warnings, these can be ignored):

```ruby
entity_id = 'https://example.edu.au/shibboleth'
information_url = 'https://example.edu.au/look-its-some-information-at-a-url'

ed = EntityId[uri: entity_id].entity_descriptor
ea = ed.entity_attribute || MDATTR::EntityAttribute.create(entity_descriptor: ed)

# SP R&S
a = Attribute.create name: 'http://macedir.org/entity-category', entity_attribute: ea
nf = NameFormat.create attribute: a, uri: 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
av = AttributeValue.create value: 'http://refeds.org/category/research-and-scholarship', attribute: a

# SP InformationURL
ed.sp_sso_descriptors.each do |rd|
  ui_info = rd.ui_info || raise('no UIInfo, should not be possible')
  next if ui_info.information_urls.any?
  MDUI::InformationURL.create(ui_info: ui_info, uri: information_url, lang: 'en')
end

# SIRTFI
a = Attribute.create name: 'urn:oasis:names:tc:SAML:attribute:assurance-certification', entity_attribute: ea
nf = NameFormat.create attribute: a, uri: 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
av = AttributeValue.create value: 'https://refeds.org/sirtfi', attribute: a

# Export to eduGAIN
ed.known_entity.tag_as('aaf-edugain-export')

# Finalize
ed.save
ed.known_entity.touch
```

Validate the EntityID will now be pushlished to the global feed:

$> http https://saml.aaf.edu.au/mdq/aaf-edugain-export/entities Accept:application/samlmetadata+xml | rg 'https://example.edu.au/shibboleth'

Advise support all is complete. On our next Metadata publish this will be pushed out to S3 and will picked up and pushed out by global
metadata aggregate in around 24 hours. Check https://technical.edugain.org/entities to ensure it shows up after those 24 hours if necessary.

#### Importing R&S SP from another federation
This is automatically handled by SAML Service.

AAF IdP will automatically release the R&S bundle of attributes.

Services marked as R&S are preferred within the AAF context.

#### Importing a non R&S SP from another federation

To import a non AAF registered SP from eduGAIN that is not considered R&S do the following:

1. Get a session on `app4.core.aaf.edu.au` 
1. Become the `saml` user, `$> sudo -iu saml`
1. Source `.app-env`
1. Change to `repository`
1. Run `rails c`
1. Run the following in the console line by line (there might be Sequel gem warnings, these can be ignored):

```ruby
entity_id = 'https://example.edu/shibboleth'
ed = EntityId[uri: entity_id].raw_entity_descriptor
ed.known_entity.tag_as('aaf-edugain-verified')

# Finalize
ed.save
ed.known_entity.touch
```

Validate the EntityID will now be ingested from the global feed:

$> http https://saml.aaf.edu.au/mdq/aaf-edugain-verified/entities Accept:application/samlmetadata+xml | rg 'https://example.edu/shibboleth'

Advise support all is complete. On our next Metadata publish this will be pushed out to S3 and will picked up and loaded by AAF IdP the next time they
update metadata.

n.b. This process will NOT result in automated IdP attribute release. IdP admins must understand what data they are releasing to a service
and explicitly add an attribute release policy to support it.

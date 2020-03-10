# config/sitemap.rb
SitemapGenerator::Sitemap.default_host = "https://www.markitplace.io" # Your Domain Name
SitemapGenerator::Sitemap.public_path = 'tmp/sitemap'
# Where you want your sitemap.xml.gz file to be uploaded.
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new( 
    aws_access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
    aws_secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
    fog_provider: 'AWS',
    fog_directory: 'markitplace-sitemaps',
    fog_region: 'us-east-2'
)

# The full path to your bucket
SitemapGenerator::Sitemap.sitemaps_host = "https://markitplace-sitemaps.s3.amazonaws.com"
# The paths that need to be included into the sitemap.
SitemapGenerator::Sitemap.create do
    add root_path
    PlanType.find_each do |plan_type|
     add plan_type_path(plan_type, locale: :en)
     add plan_type_path(plan_type, locale: :nl)
    end
    Product.find_each do |product|
     add product_path(product, locale: :en)
     add product_path(product, locale: :nl)
    end
end
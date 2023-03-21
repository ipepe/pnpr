
RSpec.describe 'Environment Variables' do
  it 'updates nginx config based on env variables' do
    system("env RAILS_ENV=production docker-compose -f docker-compose.spec.yml up -d")
    sleep 10
    output = `docker -it exec pnpr_server_1 cat /etc/nginx/conf.d/default.conf`
    expect(output).to include('production')
  end
end
require 'spec_helper'

module Landable
  module Api
    describe TemplatesController, json: true do
      routes { Landable::Engine.routes }

      describe '#preview', json: false do
        include_examples 'Authenticated API controller', :make_request
        render_views

        let(:theme) { create :theme, body: '<html><head>{% head_content %}</head><body>Theme content; page content: {{body}}</body></html>' }

        before do
          request.env['HTTP_ACCEPT'] = 'text/html'
        end

        def make_request(attributes = attributes_for(:template, theme_id: theme.id))
          post :preview, template: attributes
        end

        it 'renders JSON' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          make_request
          expect(response.status).to eq 200
          expect(last_json['template']['preview']).to be_present
        end

        it 'renders the layout without content if the body is not present' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          make_request attributes_for(:page, body: nil)
          expect(response.status).to eq 200
          expect(last_json['template']['preview']).to include('body')
        end

        it 'renders without a layout if no theme is present' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          make_request attributes_for(:page, body: 'raw content')
          expect(response.status).to eq 200
          expect(last_json['template']['preview']).to include('raw content')
        end
      end
    end
  end
end

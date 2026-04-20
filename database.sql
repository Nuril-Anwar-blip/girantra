-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.categories (
  category_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  category_name character varying NOT NULL UNIQUE,
  description text,
  icon_url text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT categories_pkey PRIMARY KEY (category_id)
);
CREATE TABLE public.favorites (
  favorite_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  product_id bigint NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT favorites_pkey PRIMARY KEY (favorite_id),
  CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) REFERENCES public.users(user_id),
  CONSTRAINT fk_favorites_product FOREIGN KEY (product_id) REFERENCES public.products(product_id)
);
CREATE TABLE public.logistics (
  logistic_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  transaction_id bigint NOT NULL UNIQUE,
  courier_name character varying NOT NULL,
  tracking_number character varying NOT NULL UNIQUE,
  current_status USER-DEFINED NOT NULL DEFAULT 'pending'::shipping_status,
  shipping_date date,
  arrival_date date,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT logistics_pkey PRIMARY KEY (logistic_id),
  CONSTRAINT fk_logistics_transaction FOREIGN KEY (transaction_id) REFERENCES public.transactions(transaction_id)
);
CREATE TABLE public.notifications (
  notification_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  title character varying NOT NULL,
  message text NOT NULL,
  is_read boolean NOT NULL DEFAULT false,
  notification_type character varying,
  related_id bigint,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (notification_id),
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES public.users(user_id)
);
CREATE TABLE public.products (
  product_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  seller_id uuid NOT NULL,
  category_id bigint NOT NULL,
  product_name character varying NOT NULL,
  description text NOT NULL,
  cost_price numeric NOT NULL,
  selling_price numeric NOT NULL,
  ai_recommended_price numeric,
  stock bigint NOT NULL DEFAULT 0 CHECK (stock >= 0),
  unit character varying NOT NULL DEFAULT 'Kg'::character varying,
  image_url text,
  harvest_date date,
  status_product USER-DEFINED NOT NULL DEFAULT 'available'::product_status,
  rating numeric DEFAULT 0,
  total_reviews integer DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT products_pkey PRIMARY KEY (product_id),
  CONSTRAINT fk_products_seller FOREIGN KEY (seller_id) REFERENCES public.users(user_id),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES public.categories(category_id)
);
CREATE TABLE public.transactions (
  transaction_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  transaction_code character varying NOT NULL UNIQUE,
  buyer_id uuid NOT NULL,
  product_id bigint NOT NULL,
  seller_id uuid NOT NULL,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  price_at_purchase numeric NOT NULL,
  sub_total numeric NOT NULL,
  shipping_cost numeric DEFAULT 0,
  total_amount numeric NOT NULL,
  shipping_address text NOT NULL,
  payment_status USER-DEFINED NOT NULL DEFAULT 'pending'::payment_status,
  transaction_date timestamp with time zone NOT NULL DEFAULT now(),
  completed_date timestamp with time zone,
  CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id),
  CONSTRAINT fk_transactions_buyer FOREIGN KEY (buyer_id) REFERENCES public.users(user_id),
  CONSTRAINT fk_transactions_seller FOREIGN KEY (seller_id) REFERENCES public.users(user_id),
  CONSTRAINT fk_transactions_product FOREIGN KEY (product_id) REFERENCES public.products(product_id)
);
CREATE TABLE public.users (
  user_id uuid NOT NULL DEFAULT gen_random_uuid(),
  full_name character varying NOT NULL,
  email character varying NOT NULL UNIQUE,
  phone_number character varying,
  address text,
  role USER-DEFINED NOT NULL DEFAULT 'buyer'::user_role,
  account_status USER-DEFINED NOT NULL DEFAULT 'active'::account_status,
  avatar_url text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (user_id)
);